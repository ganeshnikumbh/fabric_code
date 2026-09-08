import json
import logging
import os
from datetime import date, timedelta
from typing import Any, Dict, List, Optional

import azure.functions as func
import requests

logging.basicConfig(level=logging.INFO)

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

# ==================================================================================================
# SHARED CONSTANTS
# ==================================================================================================

_ONBASE_APIM_BASE_URL_ENV = "ONBASE_APIM_BASE_URL"
_ONBASE_APIM_SUBSCRIPTION_KEY_ENV = "ONBASE_APIM_SUBSCRIPTION_KEY"
_ONBASE_APIM_WORKFLOW_BASE_URL_ENV = "ONBASE_APIM_WORKFLOW_BASE_URL"


# ==================================================================================================
# FUNCTION 1: GetOnBaseReport
# ==================================================================================================

DEFAULT_CUSTOM_QUERY_ID = "103"
DEFAULT_START_OFFSET_DAYS = -1
DEFAULT_END_OFFSET_DAYS = 0
DEFAULT_MAX_RESULTS = 50

SUBMIT_QUERY_PATH = "/documents/queries"
RESULTS_QUERY_PATH_TEMPLATE = "/documents/queries/{query_id}/results"
COLUMNS_QUERY_PATH_TEMPLATE = "/documents/queries/{query_id}/columns"


@app.route(route="GetOnBaseReport", methods=["GET", "POST"])
def GetOnBaseReport(req: func.HttpRequest) -> func.HttpResponse:
    logger = logging.getLogger("onbase_apim_orchestrator")
    logger.info("Function started.")

    try:
        config = _load_config(logger)
        params = _read_params(req, logger)
        start_date, end_date = _resolve_dates(params["startOffsetDays"], params["endOffsetDays"], logger)
        payload = _build_payload(params["customQueryId"], params["maxResults"], start_date, end_date, logger)
        headers = _build_headers(config, logger)
        submit_resp = _submit_query(config, headers, payload, logger)
        query_handle = _extract_handle(submit_resp, logger)
        results_resp = _get_results(config, headers, query_handle, logger)
        columns_resp = _get_columns(config, headers, query_handle, logger)
        column_lookup = _build_column_lookup(columns_resp, logger)
        mapped_rows = _map_rows(results_resp, column_lookup, logger)

        return _json_response({
            "message": "OnBase query executed successfully through APIM.",
            "inputParameters": params,
            "resolvedDates": {"startDate": start_date, "endDate": end_date},
            "queryHandle": query_handle,
            "rowCount": len(mapped_rows),
            "rows": mapped_rows
        }, 200)

    except ValueError as ex:
        logger.error("Validation error: %s", str(ex))
        return _json_response({"error": "ValidationError", "detail": str(ex)}, 400)

    except requests.HTTPError as ex:
        logger.error("HTTP error: %s", str(ex))
        body = None
        code = 502
        try:
            body = ex.response.text
            if ex.response.status_code:
                code = ex.response.status_code
        except Exception:
            body = "Unable to read response body."
        return _json_response({"error": "HttpError", "detail": str(ex), "responseBody": body}, code)

    except Exception as ex:
        logger.exception("Unhandled exception.")
        return _json_response({"error": "UnhandledException", "detail": str(ex)}, 500)


def _load_config(logger):
    url = os.environ.get(_ONBASE_APIM_BASE_URL_ENV)
    if not url:
        raise ValueError(f"Missing required environment variable: {_ONBASE_APIM_BASE_URL_ENV}")
    key = os.environ.get(_ONBASE_APIM_SUBSCRIPTION_KEY_ENV)
    logger.info("Config loaded.")
    return {"onbaseApimBaseUrl": url.rstrip("/"), "onbaseApimSubscriptionKey": key}


def _read_params(req, logger):
    cq = req.params.get("customQueryId", DEFAULT_CUSTOM_QUERY_ID)
    s = req.params.get("startOffsetDays", str(DEFAULT_START_OFFSET_DAYS))
    e = req.params.get("endOffsetDays", str(DEFAULT_END_OFFSET_DAYS))
    m = req.params.get("maxResults", str(DEFAULT_MAX_RESULTS))
    try:
        result = {"customQueryId": str(cq), "startOffsetDays": int(s), "endOffsetDays": int(e), "maxResults": int(m)}
    except ValueError:
        raise ValueError("startOffsetDays, endOffsetDays, and maxResults must be integers")
    logger.info("Params: %s", result)
    return result


def _resolve_dates(start_offset, end_offset, logger):
    today = date.today()
    s = (today + timedelta(days=start_offset)).isoformat()
    e = (today + timedelta(days=end_offset)).isoformat()
    logger.info("Dates: %s to %s", s, e)
    return s, e


def _build_payload(query_id, max_results, start_date, end_date, logger):
    payload = {
        "queryType": [{"type": "CustomQuery", "ids": [str(query_id)]}],
        "maxResults": max_results,
        "documentDateRangeCollection": [{"start": start_date, "end": end_date}]
    }
    logger.info("Payload built: %s", json.dumps(payload))
    return payload


def _build_headers(config, logger):
    headers = {"Accept": "application/json", "Content-Type": "application/json"}
    key = config.get("onbaseApimSubscriptionKey")
    if key:
        headers["Ocp-Apim-Subscription-Key"] = key
    logger.info("Headers built.")
    return headers


def _submit_query(config, headers, payload, logger):
    url = config["onbaseApimBaseUrl"] + SUBMIT_QUERY_PATH
    h = dict(headers)
    h["Hyland-Include-Item-Count"] = "true"
    logger.info("Submitting query. URL=%s", url)
    r = requests.post(url=url, headers=h, data=json.dumps(payload), timeout=120)
    r.raise_for_status()
    return r.json()


def _extract_handle(submit_resp, logger):
    handle = submit_resp.get("id")
    if not handle:
        raise ValueError("Submit response did not contain query handle 'id'")
    logger.info("Query handle: %s", handle)
    return str(handle)


def _get_results(config, headers, query_id, logger):
    url = config["onbaseApimBaseUrl"] + RESULTS_QUERY_PATH_TEMPLATE.format(query_id=query_id)
    logger.info("Getting results. URL=%s", url)
    r = requests.get(url=url, headers=headers, timeout=120)
    r.raise_for_status()
    return r.json()


def _get_columns(config, headers, query_id, logger):
    url = config["onbaseApimBaseUrl"] + COLUMNS_QUERY_PATH_TEMPLATE.format(query_id=query_id)
    logger.info("Getting columns. URL=%s", url)
    r = requests.get(url=url, headers=headers, timeout=120)
    r.raise_for_status()
    return r.json()


def _build_column_lookup(columns_resp, logger):
    lookup = {}
    for item in columns_resp.get("items", []):
        idx = item.get("index")
        if idx is None:
            continue
        heading = item.get("heading", "").strip()
        lookup[str(idx)] = heading if heading else f"column_{idx}"
    logger.info("Column lookup built. Count=%s", len(lookup))
    return lookup


def _map_rows(results_resp, column_lookup, logger):
    rows = []
    for item in results_resp.get("items", []):
        row = {"documentId": item.get("id")}
        for col in item.get("displayColumns", []):
            idx = col.get("index")
            if idx is None:
                continue
            key = column_lookup.get(str(idx), f"column_{idx}")
            val = _normalize(col.get("values", []))
            if key in row:
                row[f"{key}_{idx}"] = val
            else:
                row[key] = val
        rows.append(row)
    logger.info("Mapped %s rows.", len(rows))
    return rows


def _normalize(values):
    if not isinstance(values, list) or len(values) == 0:
        return None
    if len(values) == 1:
        return values[0]
    return values


def _json_response(payload, status_code):
    return func.HttpResponse(
        json.dumps(payload, indent=4),
        status_code=status_code,
        mimetype="application/json"
    )


# ==================================================================================================
# FUNCTION 2: GetOnBaseDocumentDetails
# ==================================================================================================

_DD_MAX_BATCH_SIZE = 25
_DD_REQUEST_FIELD = "documentIds"
_DD_KEYWORDS_PATH = "/documents/{document_id}/keywords"
_DD_HISTORY_PATH = "/documents/{document_id}/history"


@app.route(route="GetOnBaseDocumentDetails", methods=["POST"])
def GetOnBaseDocumentDetails(req: func.HttpRequest) -> func.HttpResponse:
    logger = logging.getLogger("onbase_document_detail_batch")
    logger.info("Function started. Beginning batch document detail enrichment.")

    try:
        config = _dd_load_config(logger)
        document_ids = _dd_read_document_ids(req, logger)
        headers = _dd_build_headers(config, logger)

        rows = []
        for document_id in document_ids:
            rows.append(_dd_build_row(config, headers, document_id, logger))

        return _dd_json_response({
            "message": "OnBase document detail batch executed through APIM.",
            "batchSize": len(document_ids),
            "rows": rows
        }, 200)

    except ValueError as ex:
        logger.error("Validation/configuration error: %s", str(ex))
        return _dd_json_response({"error": "ValidationError", "detail": str(ex)}, 400)

    except Exception as ex:
        logger.exception("Unhandled exception occurred.")
        return _dd_json_response({"error": "UnhandledException", "detail": str(ex)}, 500)


def _dd_load_config(logger: logging.Logger) -> Dict[str, str]:
    url = os.environ.get(_ONBASE_APIM_BASE_URL_ENV)
    if not url:
        raise ValueError(f"Missing required environment variable: {_ONBASE_APIM_BASE_URL_ENV}")
    key = os.environ.get(_ONBASE_APIM_SUBSCRIPTION_KEY_ENV)
    logger.info("Configuration loaded successfully.")
    return {"onbaseApimBaseUrl": url.rstrip("/"), "onbaseApimSubscriptionKey": key}


def _dd_read_document_ids(req: func.HttpRequest, logger: logging.Logger) -> List[str]:
    try:
        body = req.get_json()
    except ValueError:
        raise ValueError(f"Request body must be valid JSON containing '{_DD_REQUEST_FIELD}'")

    document_ids = body.get(_DD_REQUEST_FIELD) if body else None

    if not document_ids or not isinstance(document_ids, list):
        raise ValueError(f"Request body must include a non-empty '{_DD_REQUEST_FIELD}' array")

    normalized = [str(d).strip() for d in document_ids]

    if any(not d for d in normalized):
        raise ValueError(f"'{_DD_REQUEST_FIELD}' array must not contain blank/empty values")

    deduped = list(dict.fromkeys(normalized))

    if len(deduped) > _DD_MAX_BATCH_SIZE:
        raise ValueError(
            f"documentIds batch size ({len(deduped)}) exceeds MAX_BATCH_SIZE ({_DD_MAX_BATCH_SIZE})"
        )

    logger.info("Document IDs resolved. Batch size=%s", len(deduped))
    return deduped


def _dd_build_headers(config: Dict[str, str], logger: logging.Logger) -> Dict[str, str]:
    headers = {"Accept": "application/json", "Content-Type": "application/json"}
    key = config.get("onbaseApimSubscriptionKey")
    if key:
        headers["Ocp-Apim-Subscription-Key"] = key
    logger.info("APIM headers built.")
    return headers


def _dd_build_row(
    config: Dict[str, str],
    headers: Dict[str, str],
    document_id: str,
    logger: logging.Logger
) -> Dict[str, Any]:
    try:
        keywords = _dd_get_keywords(config, headers, document_id, logger)
        history = _dd_get_history(config, headers, document_id, logger)
        return {"documentId": document_id, "keywords": keywords, "history": history}
    except requests.HTTPError as ex:
        logger.error("HTTP error enriching documentId=%s: %s", document_id, str(ex))
        return {"documentId": document_id, "error": str(ex)}
    except Exception as ex:
        logger.exception("Unhandled error enriching documentId=%s", document_id)
        return {"documentId": document_id, "error": str(ex)}


def _dd_get_keywords(
    config: Dict[str, str],
    headers: Dict[str, str],
    document_id: str,
    logger: logging.Logger
) -> Dict[str, Any]:
    url = config["onbaseApimBaseUrl"] + _DD_KEYWORDS_PATH.format(document_id=document_id)
    logger.info("Retrieving keywords. URL=%s", url)
    r = requests.get(url=url, headers=headers, timeout=120)
    r.raise_for_status()
    return r.json()


def _dd_get_history(
    config: Dict[str, str],
    headers: Dict[str, str],
    document_id: str,
    logger: logging.Logger
) -> Dict[str, Any]:
    url = config["onbaseApimBaseUrl"] + _DD_HISTORY_PATH.format(document_id=document_id)
    logger.info("Retrieving history. URL=%s", url)
    r = requests.get(url=url, headers=headers, timeout=120)
    r.raise_for_status()
    return r.json()


def _dd_json_response(payload: Dict[str, Any], status_code: int) -> func.HttpResponse:
    return func.HttpResponse(
        json.dumps(payload, indent=4),
        status_code=status_code,
        mimetype="application/json"
    )


# ==================================================================================================
# FUNCTION 3: GetOnBaseKeywordTypes
# ==================================================================================================

_KT_KEYWORD_TYPES_PATH = "/keyword-types"


@app.route(route="GetOnBaseKeywordTypes", methods=["GET"])
def GetOnBaseKeywordTypes(req: func.HttpRequest) -> func.HttpResponse:
    logger = logging.getLogger("onbase_keyword_type_catalog")
    logger.info("Function started. Retrieving OnBase keyword type catalog.")

    try:
        config = _kt_load_config(logger)
        headers = _kt_build_headers(config, logger)
        keyword_types_response = _kt_get_keyword_types(config, headers, logger)
        items = keyword_types_response.get("items", [])

        return _kt_json_response({
            "message": "OnBase keyword type catalog retrieved through APIM.",
            "keywordTypeCount": len(items),
            "items": items
        }, 200)

    except ValueError as ex:
        logger.error("Validation/configuration error: %s", str(ex))
        return _kt_json_response({"error": "ValidationError", "detail": str(ex)}, 400)

    except requests.HTTPError as ex:
        logger.error("HTTP error during APIM/OnBase interaction: %s", str(ex))
        response_text = None
        status_code = 502
        try:
            response_text = ex.response.text
            if ex.response.status_code:
                status_code = ex.response.status_code
        except Exception:
            response_text = "Unable to read HTTP response body."
        return _kt_json_response({
            "error": "HttpError",
            "detail": str(ex),
            "responseBody": response_text
        }, status_code)

    except Exception as ex:
        logger.exception("Unhandled exception occurred.")
        return _kt_json_response({"error": "UnhandledException", "detail": str(ex)}, 500)


def _kt_load_config(logger: logging.Logger) -> Dict[str, str]:
    url = os.environ.get(_ONBASE_APIM_BASE_URL_ENV)
    if not url:
        raise ValueError(f"Missing required environment variable: {_ONBASE_APIM_BASE_URL_ENV}")
    key = os.environ.get(_ONBASE_APIM_SUBSCRIPTION_KEY_ENV)
    logger.info("Configuration loaded successfully.")
    return {"onbaseApimBaseUrl": url.rstrip("/"), "onbaseApimSubscriptionKey": key}


def _kt_build_headers(config: Dict[str, str], logger: logging.Logger) -> Dict[str, str]:
    headers = {"Accept": "application/json", "Content-Type": "application/json"}
    key = config.get("onbaseApimSubscriptionKey")
    if key:
        headers["Ocp-Apim-Subscription-Key"] = key
    logger.info("APIM headers built successfully.")
    return headers


def _kt_get_keyword_types(
    config: Dict[str, str],
    headers: Dict[str, str],
    logger: logging.Logger
) -> Dict[str, Any]:
    url = config["onbaseApimBaseUrl"] + _KT_KEYWORD_TYPES_PATH
    logger.info("Retrieving keyword type catalog through APIM. URL=%s", url)
    r = requests.get(url=url, headers=headers, timeout=120)
    r.raise_for_status()
    logger.info("Keyword type catalog retrieved successfully.")
    return r.json()


def _kt_json_response(payload: Dict[str, Any], status_code: int) -> func.HttpResponse:
    return func.HttpResponse(
        json.dumps(payload, indent=4),
        status_code=status_code,
        mimetype="application/json"
    )


# ==================================================================================================
# FUNCTION 4: GetOnBaseQueues
# ==================================================================================================

_Q_QUEUES_PATH = "/queues"


@app.route(route="GetOnBaseQueues", methods=["GET"])
def GetOnBaseQueues(req: func.HttpRequest) -> func.HttpResponse:
    logger = logging.getLogger("onbase_workflow_queue_catalog")
    logger.info("Function started. Retrieving OnBase workflow queue catalog.")

    try:
        config = _q_load_config(logger)
        headers = _q_build_headers(config, logger)
        queues_response = _q_get_queues(config, headers, logger)
        items = queues_response.get("items", [])

        return _q_json_response({
            "message": "OnBase workflow queue catalog retrieved through APIM.",
            "queueCount": len(items),
            "items": items
        }, 200)

    except ValueError as ex:
        logger.error("Validation/configuration error: %s", str(ex))
        return _q_json_response({"error": "ValidationError", "detail": str(ex)}, 400)

    except requests.HTTPError as ex:
        logger.error("HTTP error during APIM/OnBase interaction: %s", str(ex))
        response_text = None
        status_code = 502
        try:
            response_text = ex.response.text
            if ex.response.status_code:
                status_code = ex.response.status_code
        except Exception:
            response_text = "Unable to read HTTP response body."
        return _q_json_response({
            "error": "HttpError",
            "detail": str(ex),
            "responseBody": response_text
        }, status_code)

    except Exception as ex:
        logger.exception("Unhandled exception occurred.")
        return _q_json_response({"error": "UnhandledException", "detail": str(ex)}, 500)


def _q_load_config(logger: logging.Logger) -> Dict[str, str]:
    workflow_url = os.environ.get(_ONBASE_APIM_WORKFLOW_BASE_URL_ENV)
    base_url = os.environ.get(_ONBASE_APIM_BASE_URL_ENV)
    resolved_url = workflow_url or base_url

    if not resolved_url:
        raise ValueError(
            f"Missing required environment variable: set {_ONBASE_APIM_WORKFLOW_BASE_URL_ENV} "
            f"or {_ONBASE_APIM_BASE_URL_ENV}"
        )

    if not workflow_url:
        logger.warning(
            "%s is not set. Falling back to %s. If /queues returns 404, "
            "the Workflow API requires its own base URL.",
            _ONBASE_APIM_WORKFLOW_BASE_URL_ENV,
            _ONBASE_APIM_BASE_URL_ENV
        )

    key = os.environ.get(_ONBASE_APIM_SUBSCRIPTION_KEY_ENV)
    logger.info("Configuration loaded successfully.")
    return {"onbaseApimBaseUrl": resolved_url.rstrip("/"), "onbaseApimSubscriptionKey": key}


def _q_build_headers(config: Dict[str, str], logger: logging.Logger) -> Dict[str, str]:
    headers = {"Accept": "application/json", "Content-Type": "application/json"}
    key = config.get("onbaseApimSubscriptionKey")
    if key:
        headers["Ocp-Apim-Subscription-Key"] = key
    logger.info("APIM headers built successfully.")
    return headers


def _q_get_queues(
    config: Dict[str, str],
    headers: Dict[str, str],
    logger: logging.Logger
) -> Dict[str, Any]:
    url = config["onbaseApimBaseUrl"] + _Q_QUEUES_PATH
    logger.info("Retrieving workflow queue catalog through APIM. URL=%s", url)
    r = requests.get(url=url, headers=headers, timeout=120)
    r.raise_for_status()
    logger.info("Workflow queue catalog retrieved successfully.")
    return r.json()


def _q_json_response(payload: Dict[str, Any], status_code: int) -> func.HttpResponse:
    return func.HttpResponse(
        json.dumps(payload, indent=4),
        status_code=status_code,
        mimetype="application/json"
    )


# ==================================================================================================
# FUNCTION 5: GetOnBaseQueueWorkItems
# ==================================================================================================

_QWI_REQUEST_FIELD_QUEUE_ID = "queueId"
_QWI_REQUEST_FIELD_MAX_RESULTS = "maxResults"
_QWI_REQUEST_FIELD_FILTER_ID = "filterId"
_QWI_REQUEST_FIELD_APPLY_DEFAULT_FILTER = "applyDefaultFilter"
_QWI_REQUEST_FIELD_QUERY_TYPE = "queryType"

_QWI_DEFAULT_QUERY_TYPE = "CurrentUserWorkItems"
_QWI_DEFAULT_MAX_RESULTS = 2000
_QWI_DEFAULT_APPLY_DEFAULT_FILTER = False

_QWI_TRUE_STRINGS = frozenset(["true", "1", "yes", "y"])
_QWI_FALSE_STRINGS = frozenset(["false", "0", "no", "n"])

_QWI_WORK_ITEM_TYPE_DOCUMENT = "Document"
_QWI_QUEUE_WORK_ITEMS_PATH_TEMPLATE = "/queues/{queue_id}/work-items"


@app.route(route="GetOnBaseQueueWorkItems", methods=["POST"])
def GetOnBaseQueueWorkItems(req: func.HttpRequest) -> func.HttpResponse:
    logger = logging.getLogger("onbase_queue_work_items")
    logger.info("Function started. Retrieving OnBase workflow queue work items.")

    try:
        config = _qwi_load_config(logger)
        request_parameters = _qwi_read_request_parameters(req=req, logger=logger)
        headers = _qwi_build_apim_headers(logger=logger, config=config)
        query_body = _qwi_build_query_body(logger=logger, request_parameters=request_parameters)
        queue_response = _qwi_get_queue_work_items(
            logger=logger,
            config=config,
            headers=headers,
            queue_id=request_parameters["queueId"],
            query_body=query_body
        )

        column_configuration = queue_response.get("displayColumns") or []
        raw_items = queue_response.get("items") or []

        heading_by_index = _qwi_build_heading_lookup(column_configuration=column_configuration)

        flattened_items = [
            _qwi_build_work_item_row(raw_item=raw_item, heading_by_index=heading_by_index)
            for raw_item in raw_items
        ]

        max_results = request_parameters["maxResults"]
        work_item_count = len(flattened_items)
        truncation_suspected = work_item_count >= max_results

        if truncation_suspected:
            logger.warning(
                "Result count (%s) reached maxResults (%s) for queueId=%s. "
                "OnBase does not paginate or report a total, so this queue may "
                "hold more items than were returned. Re-run with a higher "
                "maxResults to confirm.",
                work_item_count,
                max_results,
                request_parameters["queueId"]
            )

        return _qwi_build_json_response({
            "message": "OnBase workflow queue work items retrieved through APIM.",
            "queueId": request_parameters["queueId"],
            "maxResults": max_results,
            "filterIdApplied": queue_response.get("filterId"),
            "workItemCount": work_item_count,
            "truncationSuspected": truncation_suspected,
            "displayColumns": column_configuration,
            "items": flattened_items
        }, 200)

    except ValueError as ex:
        logger.error("Validation/configuration error: %s", str(ex))
        return _qwi_build_json_response({"error": "ValidationError", "detail": str(ex)}, 400)

    except requests.HTTPError as ex:
        logger.error("HTTP error during APIM/OnBase interaction: %s", str(ex))
        response_text = None
        status_code = 502
        try:
            response_text = ex.response.text
            if ex.response.status_code and ex.response.status_code >= 400:
                status_code = ex.response.status_code
        except Exception:
            response_text = "Unable to read HTTP response body."
        return _qwi_build_json_response({
            "error": "HttpError",
            "detail": str(ex),
            "responseBody": response_text
        }, status_code)

    except Exception as ex:
        logger.exception("Unhandled exception occurred.")
        return _qwi_build_json_response({"error": "UnhandledException", "detail": str(ex)}, 500)


def _qwi_load_config(logger: logging.Logger) -> Dict[str, str]:
    workflow_url = os.environ.get(_ONBASE_APIM_WORKFLOW_BASE_URL_ENV)
    base_url = os.environ.get(_ONBASE_APIM_BASE_URL_ENV)
    resolved_url = workflow_url

    if not resolved_url:
        logger.warning(
            "ONBASE_APIM_WORKFLOW_BASE_URL is not set. Falling back to "
            "ONBASE_APIM_BASE_URL, which points at the DOCUMENT API (onbase/core) "
            "and does not expose /queues. Expect 404. Set the workflow base URL."
        )
        resolved_url = base_url

    if not resolved_url:
        raise ValueError(
            "Missing required environment variable: ONBASE_APIM_WORKFLOW_BASE_URL"
        )

    key = os.environ.get(_ONBASE_APIM_SUBSCRIPTION_KEY_ENV)
    logger.info("Configuration loaded successfully.")
    return {
        "onbaseApimWorkflowBaseUrl": resolved_url.rstrip("/"),
        "onbaseApimSubscriptionKey": key
    }


def _qwi_read_request_body(req: func.HttpRequest) -> Dict[str, Any]:
    try:
        parsed_body = req.get_json()
    except ValueError:
        return {}
    if isinstance(parsed_body, dict):
        return parsed_body
    return {}


def _qwi_resolve_raw_parameter(
    req: func.HttpRequest,
    body: Dict[str, Any],
    field_name: str
) -> Any:
    route_value = req.route_params.get(field_name)
    if route_value is not None:
        return route_value
    query_value = req.params.get(field_name)
    if query_value is not None:
        return query_value
    return body.get(field_name)


def _qwi_coerce_to_int(raw_value: Any, field_name: str) -> int:
    if isinstance(raw_value, bool):
        raise ValueError(f"'{field_name}' must be an integer, received a boolean")
    try:
        return int(str(raw_value).strip())
    except (TypeError, ValueError):
        raise ValueError(f"'{field_name}' must be an integer, received: {raw_value!r}")


def _qwi_coerce_to_bool(raw_value: Any, field_name: str) -> bool:
    if isinstance(raw_value, bool):
        return raw_value
    normalized = str(raw_value).strip().lower()
    if normalized in _QWI_TRUE_STRINGS:
        return True
    if normalized in _QWI_FALSE_STRINGS:
        return False
    raise ValueError(f"'{field_name}' must be true or false, received: {raw_value!r}")


def _qwi_read_request_parameters(
    req: func.HttpRequest,
    logger: logging.Logger
) -> Dict[str, Any]:
    body = _qwi_read_request_body(req)

    raw_queue_id = _qwi_resolve_raw_parameter(
        req=req, body=body, field_name=_QWI_REQUEST_FIELD_QUEUE_ID
    )
    if raw_queue_id is None:
        raise ValueError(
            f"'{_QWI_REQUEST_FIELD_QUEUE_ID}' is required. Supply it as a route parameter, "
            f"a query string parameter, or a field in the JSON body."
        )
    queue_id = str(raw_queue_id).strip()
    if not queue_id:
        raise ValueError(f"'{_QWI_REQUEST_FIELD_QUEUE_ID}' must not be blank")

    raw_max_results = _qwi_resolve_raw_parameter(
        req=req, body=body, field_name=_QWI_REQUEST_FIELD_MAX_RESULTS
    )
    max_results = _QWI_DEFAULT_MAX_RESULTS
    if raw_max_results is not None:
        max_results = _qwi_coerce_to_int(
            raw_value=raw_max_results, field_name=_QWI_REQUEST_FIELD_MAX_RESULTS
        )
    if max_results < 1:
        raise ValueError(
            f"'{_QWI_REQUEST_FIELD_MAX_RESULTS}' must be 1 or greater, received: {max_results}"
        )

    raw_filter_id = _qwi_resolve_raw_parameter(
        req=req, body=body, field_name=_QWI_REQUEST_FIELD_FILTER_ID
    )
    filter_id = None
    if raw_filter_id is not None and str(raw_filter_id).strip() != "":
        filter_id = _qwi_coerce_to_int(
            raw_value=raw_filter_id, field_name=_QWI_REQUEST_FIELD_FILTER_ID
        )

    raw_apply_default_filter = _qwi_resolve_raw_parameter(
        req=req, body=body, field_name=_QWI_REQUEST_FIELD_APPLY_DEFAULT_FILTER
    )
    apply_default_filter = _QWI_DEFAULT_APPLY_DEFAULT_FILTER
    if raw_apply_default_filter is not None:
        apply_default_filter = _qwi_coerce_to_bool(
            raw_value=raw_apply_default_filter,
            field_name=_QWI_REQUEST_FIELD_APPLY_DEFAULT_FILTER
        )

    raw_query_type = _qwi_resolve_raw_parameter(
        req=req, body=body, field_name=_QWI_REQUEST_FIELD_QUERY_TYPE
    )
    query_type = str(raw_query_type).strip() if raw_query_type else _QWI_DEFAULT_QUERY_TYPE

    request_parameters = {
        "queueId": queue_id,
        "queryType": query_type,
        "maxResults": max_results,
        "filterId": filter_id,
        "applyDefaultFilter": apply_default_filter
    }

    logger.info(
        "Request parameters resolved. queueId=%s maxResults=%s filterId=%s applyDefaultFilter=%s",
        queue_id, max_results, filter_id, apply_default_filter
    )
    return request_parameters


def _qwi_build_apim_headers(
    logger: logging.Logger,
    config: Dict[str, str]
) -> Dict[str, str]:
    headers = {"Accept": "application/json", "Content-Type": "application/json"}
    subscription_key = config.get("onbaseApimSubscriptionKey")
    if subscription_key:
        headers["Ocp-Apim-Subscription-Key"] = subscription_key
    logger.info("APIM headers built successfully.")
    return headers


def _qwi_build_query_body(
    logger: logging.Logger,
    request_parameters: Dict[str, Any]
) -> Dict[str, Any]:
    query_body = {
        _QWI_REQUEST_FIELD_QUERY_TYPE: request_parameters["queryType"],
        _QWI_REQUEST_FIELD_MAX_RESULTS: request_parameters["maxResults"]
    }
    filter_id = request_parameters.get("filterId")
    if filter_id is not None:
        query_body[_QWI_REQUEST_FIELD_FILTER_ID] = filter_id
        logger.info(
            "filterId supplied. applyDefaultFilter omitted -- the two are mutually exclusive in OnBase."
        )
    else:
        query_body[_QWI_REQUEST_FIELD_APPLY_DEFAULT_FILTER] = request_parameters["applyDefaultFilter"]
    logger.info("Outbound query body built successfully.")
    return query_body


def _qwi_get_queue_work_items(
    logger: logging.Logger,
    config: Dict[str, str],
    headers: Dict[str, str],
    queue_id: str,
    query_body: Dict[str, Any]
) -> Dict[str, Any]:
    path = _QWI_QUEUE_WORK_ITEMS_PATH_TEMPLATE.format(queue_id=queue_id)
    url = f'{config["onbaseApimWorkflowBaseUrl"]}{path}'
    logger.info("Retrieving queue work items through APIM. URL=%s", url)

    response = requests.post(
        url=url,
        headers=headers,
        data=json.dumps(query_body),
        timeout=120
    )
    response.raise_for_status()

    try:
        parsed_response = response.json()
    except Exception:
        logger.error(
            "Upstream returned a non-JSON body on a successful status code. "
            "This is usually an APIM error page rather than an OnBase response."
        )
        raise requests.HTTPError(
            "Upstream returned a non-JSON body on a successful status code.",
            response=response
        )

    logger.info("Queue work items retrieved successfully. queueId=%s", queue_id)
    return parsed_response


def _qwi_build_heading_lookup(
    column_configuration: List[Dict[str, Any]]
) -> Dict[str, str]:
    heading_by_index = {}
    used_headings = set()

    for column in column_configuration:
        index = column.get("index")
        if index is None:
            continue
        heading = column.get("heading") or f"column_{index}"
        unique_heading = heading
        suffix = 2
        while unique_heading in used_headings:
            unique_heading = f"{heading}_{suffix}"
            suffix = suffix + 1
        used_headings.add(unique_heading)
        heading_by_index[str(index)] = unique_heading

    return heading_by_index


def _qwi_build_work_item_row(
    raw_item: Dict[str, Any],
    heading_by_index: Dict[str, str]
) -> Dict[str, Any]:
    fields = {}
    for column in raw_item.get("displayColumns") or []:
        index = column.get("index")
        if index is None:
            continue
        index_key = str(index)
        heading = heading_by_index.get(index_key, f"column_{index_key}")
        fields[heading] = column.get("value")

    work_item_id = raw_item.get("id")
    work_item_type = raw_item.get("workItemType")
    document_id = work_item_id if work_item_type == _QWI_WORK_ITEM_TYPE_DOCUMENT else None

    return {
        "workItemId": work_item_id,
        "documentId": document_id,
        "classId": raw_item.get("classId"),
        "workItemType": work_item_type,
        "fields": fields
    }


def _qwi_build_json_response(payload: Dict[str, Any], status_code: int) -> func.HttpResponse:
    return func.HttpResponse(
        json.dumps(payload, indent=4),
        status_code=status_code,
        mimetype="application/json"
    )


# ==================================================================================================
# FUNCTION 7: DisconnectOnBaseSession
# ==================================================================================================
#
# Terminates the OnBase server-side session on both the core and workflow APIM backends.
#
# CRITICAL: Disconnect is ACCOUNT-WIDE, not call-scoped. Call this ONCE as the final
# activity of a pipeline run. Never call it per-request or inside a fan-out loop —
# doing so will silently kill in-flight calls on other parallel activities.
#
# Monitor anyEndpointMissing in the response. True means APIM has not published the
# disconnect operation on at least one backend — that is a misconfiguration, not a no-op.
# Pipeline check: @activity('DisconnectSession').output.anyEndpointMissing
# ==================================================================================================

_SD_SESSION_DISCONNECT_PATH = "session/disconnect"
_SD_REQUEST_TIMEOUT_SECONDS = 30
_SD_BACKEND_CORE = "core"
_SD_BACKEND_WORKFLOW = "workflow"


@app.route(route="DisconnectOnBaseSession", methods=["POST"])
def DisconnectOnBaseSession(req: func.HttpRequest) -> func.HttpResponse:
    logger = logging.getLogger("onbase_session_disconnect")
    logger.info("Function started. Disconnecting OnBase sessions on all configured backends.")

    try:
        config = _sd_load_config(logger)
        headers = _sd_build_apim_headers(config, logger)
        results = _sd_disconnect_all_backends(config["backendBaseUrls"], headers, logger)
        return _sd_json_response(_sd_summarize_results(results), 200)

    except ValueError as ex:
        logger.error("Configuration error: %s", str(ex))
        return _sd_json_response({"error": str(ex)}, 500)

    except requests.RequestException as ex:
        logger.error("Network error contacting APIM: %s", str(ex))
        return _sd_json_response({"error": str(ex)}, 504)


def _sd_load_config(logger: logging.Logger) -> Dict[str, Any]:
    core_url = os.environ.get("ONBASE_APIM_CORE_BASE_URL") or os.environ.get(_ONBASE_APIM_BASE_URL_ENV)
    workflow_url = os.environ.get(_ONBASE_APIM_WORKFLOW_BASE_URL_ENV)
    key = os.environ.get(_ONBASE_APIM_SUBSCRIPTION_KEY_ENV)

    if not core_url and not workflow_url:
        raise ValueError(
            "Missing required environment variables: set at least one of "
            "ONBASE_APIM_CORE_BASE_URL or ONBASE_APIM_WORKFLOW_BASE_URL"
        )

    logger.info("Configuration loaded. core=%s workflow=%s", bool(core_url), bool(workflow_url))
    return {
        "backendBaseUrls": {
            _SD_BACKEND_CORE: core_url.rstrip("/") if core_url else None,
            _SD_BACKEND_WORKFLOW: workflow_url.rstrip("/") if workflow_url else None
        },
        "onbaseApimSubscriptionKey": key
    }


def _sd_build_apim_headers(config: Dict[str, Any], logger: logging.Logger) -> Dict[str, str]:
    headers = {"Accept": "application/json", "Content-Type": "application/json"}
    key = config.get("onbaseApimSubscriptionKey")
    if key:
        headers["Ocp-Apim-Subscription-Key"] = key
    logger.info("APIM headers built.")
    return headers


def _sd_disconnect_all_backends(
    backend_base_urls: Dict[str, Any],
    headers: Dict[str, str],
    logger: logging.Logger
) -> List[Dict[str, Any]]:
    results = []
    for backend_name in (_SD_BACKEND_CORE, _SD_BACKEND_WORKFLOW):
        base_url = backend_base_urls.get(backend_name)
        if not base_url:
            logger.info("Backend %s is not configured. Skipping.", backend_name)
            results.append(_sd_unconfigured_result(backend_name))
            continue
        results.append(_sd_disconnect_backend(backend_name, base_url, headers, logger))
    return results


def _sd_disconnect_backend(
    backend_name: str,
    base_url: str,
    headers: Dict[str, str],
    logger: logging.Logger
) -> Dict[str, Any]:
    url = f"{base_url}/{_SD_SESSION_DISCONNECT_PATH}"
    logger.info("Disconnecting OnBase session. backend=%s URL=%s", backend_name, url)

    response = requests.post(url=url, headers=headers, timeout=_SD_REQUEST_TIMEOUT_SECONDS)

    if response.ok:
        logger.info("Session disconnected successfully. backend=%s", backend_name)
        return _sd_backend_result(backend_name, disconnected=True, endpoint_missing=False, status_code=response.status_code)

    if response.status_code == 404:
        logger.error(
            "Disconnect path not found — verify APIM publishes the operation. backend=%s URL=%s",
            backend_name, url
        )
        return _sd_backend_result(backend_name, disconnected=False, endpoint_missing=True, status_code=response.status_code)

    logger.warning("Disconnect returned HTTP %s. Treating as no active session. backend=%s", response.status_code, backend_name)
    return _sd_backend_result(backend_name, disconnected=False, endpoint_missing=False, status_code=response.status_code)


def _sd_backend_result(
    backend_name: str,
    disconnected: bool,
    endpoint_missing: bool,
    status_code: int
) -> Dict[str, Any]:
    return {
        "backend": backend_name,
        "configured": True,
        "disconnected": disconnected,
        "endpointMissing": endpoint_missing,
        "statusCode": status_code
    }


def _sd_unconfigured_result(backend_name: str) -> Dict[str, Any]:
    return {
        "backend": backend_name,
        "configured": False,
        "disconnected": False,
        "endpointMissing": False,
        "statusCode": None
    }


def _sd_summarize_results(results: List[Dict[str, Any]]) -> Dict[str, Any]:
    return {
        "message": "OnBase session disconnect attempted on all configured backends.",
        "results": results,
        "anyDisconnected": any(r["disconnected"] for r in results),
        "anyEndpointMissing": any(r["endpointMissing"] for r in results)
    }


def _sd_json_response(payload: Dict[str, Any], status_code: int) -> func.HttpResponse:
    return func.HttpResponse(
        json.dumps(payload, indent=4),
        status_code=status_code,
        mimetype="application/json"
    )
# ==================================================================================================
# FUNCTION 6: GetOnBaseDocumentTypes
# ==================================================================================================

_DT_DOCUMENT_TYPES_PATH = "/document-types"


@app.route(route="GetOnBaseDocumentTypes", methods=["GET"])
def GetOnBaseDocumentTypes(req: func.HttpRequest) -> func.HttpResponse:
    logger = logging.getLogger("onbase_document_type_catalog")
    logger.info("Function started. Retrieving OnBase document type catalog.")

    try:
        config = _dt_load_config(logger)
        headers = _dt_build_headers(config, logger)
        document_types_response = _dt_get_document_types(config, headers, logger)
        items = document_types_response.get("items", [])

        return _dt_json_response({
            "message": "OnBase document type catalog retrieved through APIM.",
            "documentTypeCount": len(items),
            "items": items
        }, 200)

    except ValueError as ex:
        logger.error("Validation/configuration error: %s", str(ex))
        return _dt_json_response({"error": "ValidationError", "detail": str(ex)}, 400)

    except requests.HTTPError as ex:
        logger.error("HTTP error during APIM/OnBase interaction: %s", str(ex))
        response_text = None
        status_code = 502
        try:
            response_text = ex.response.text
            if ex.response.status_code:
                status_code = ex.response.status_code
        except Exception:
            response_text = "Unable to read HTTP response body."
        return _dt_json_response({
            "error": "HttpError",
            "detail": str(ex),
            "responseBody": response_text
        }, status_code)

    except Exception as ex:
        logger.exception("Unhandled exception occurred.")
        return _dt_json_response({"error": "UnhandledException", "detail": str(ex)}, 500)


def _dt_load_config(logger: logging.Logger) -> Dict[str, str]:
    url = os.environ.get(_ONBASE_APIM_BASE_URL_ENV)
    if not url:
        raise ValueError(f"Missing required environment variable: {_ONBASE_APIM_BASE_URL_ENV}")
    key = os.environ.get(_ONBASE_APIM_SUBSCRIPTION_KEY_ENV)
    logger.info("Configuration loaded successfully.")
    return {"onbaseApimBaseUrl": url.rstrip("/"), "onbaseApimSubscriptionKey": key}


def _dt_build_headers(config: Dict[str, str], logger: logging.Logger) -> Dict[str, str]:
    headers = {"Accept": "application/json", "Content-Type": "application/json"}
    key = config.get("onbaseApimSubscriptionKey")
    if key:
        headers["Ocp-Apim-Subscription-Key"] = key
    logger.info("APIM headers built successfully.")
    return headers


def _dt_get_document_types(
    config: Dict[str, str],
    headers: Dict[str, str],
    logger: logging.Logger
) -> Dict[str, Any]:
    url = config["onbaseApimBaseUrl"] + _DT_DOCUMENT_TYPES_PATH
    logger.info("Retrieving document type catalog through APIM. URL=%s", url)
    r = requests.get(url=url, headers=headers, timeout=120)
    r.raise_for_status()
    logger.info("Document type catalog retrieved successfully.")
    return r.json()


def _dt_json_response(payload: Dict[str, Any], status_code: int) -> func.HttpResponse:
    return func.HttpResponse(
        json.dumps(payload, indent=4),
        status_code=status_code,
        mimetype="application/json"
    )


# ==================================================================================================
# FUNCTION 8: GetOnBaseDocTypeKeywords
# ==================================================================================================

# ==================================================================================================
# REQUEST PARAMETERS
# ==================================================================================================
#
# documentTypeId        REQUIRED. The OnBase document type to describe.
#
# Query string values always arrive as strings. documentTypeId is deliberately LEFT as a string.
# OnBase types these identifiers as strings in the API contract, and coercing to int would drop
# leading zeros and fail outright on any non-numeric identifier.
# ==================================================================================================


# ==================================================================================================
# APIM PATHS
# ==================================================================================================

_DTK_KEYWORD_GROUPS_PATH = "/document-types/{documentTypeId}/keyword-type-groups"

@app.route(route="GetOnBaseDocTypeKeywords", methods=["GET"])
def GetOnBaseDocTypeKeywords(req: func.HttpRequest) -> func.HttpResponse:
        """
        ============================================================================================
        MAIN ENTRY POINT
        ============================================================================================

        This is the single HTTP-triggered entry point.

        APIM calls THIS.
        THIS function orchestrates everything else.
        """

        logger = logging.getLogger("onbase_document_type_keywords")
        logger.info("Function started. Retrieving OnBase document type catalog.")

        logger.info("Function started. Retrieving OnBase document type keyword associations.")

        try:
                # -----------------------------------------------------------------------------------
                # STEP 1: LOAD CONFIGURATION
                # -----------------------------------------------------------------------------------
                config = _dtk_load_config(logger)

                # -----------------------------------------------------------------------------------
                # STEP 2: READ REQUEST PARAMETERS
                # -----------------------------------------------------------------------------------
                document_type_id = _dtk_read_request_document_type_id(
                        logger=logger,
                        req=req
                )

                # -----------------------------------------------------------------------------------
                # STEP 3: BUILD HEADERS FOR CALLING APIM
                # -----------------------------------------------------------------------------------
                headers = _dtk_build_apim_headers(
                        logger=logger,
                        config=config
                )

                # -----------------------------------------------------------------------------------
                # STEP 4: GET THE KEYWORD TYPE GROUPS FOR THIS DOCUMENT TYPE
                # -----------------------------------------------------------------------------------
                keyword_groups_response = _dtk_get_document_type_keyword_groups(
                        logger=logger,
                        config=config,
                        headers=headers,
                        document_type_id=document_type_id
                )

                # -----------------------------------------------------------------------------------
                # STEP 5: MAP RAW GROUPS INTO CLEAN ROWS
                # -----------------------------------------------------------------------------------
                items = _dtk_map_keyword_groups_to_rows(
                        logger=logger,
                        keyword_groups_response=keyword_groups_response,
                        document_type_id=document_type_id
                )

                # -----------------------------------------------------------------------------------
                # STEP 6: RETURN CLEAN RESPONSE
                # -----------------------------------------------------------------------------------
                final_response = {
                        "message": "OnBase document type keyword associations retrieved through APIM.",
                        "documentTypeId": document_type_id,
                        "keywordTypeCount": len(items),
                        "items": items
                }

                return _dtk_build_json_response(
                        payload=final_response,
                        status_code=200
                )

        except ValueError as ex:
                logger.error("Validation/configuration error: %s", str(ex))

                return _dtk_build_json_response(
                        payload={
                                "error": "ValidationError",
                                "detail": str(ex)
                        },
                        status_code=400
                )

        except requests.HTTPError as ex:
                logger.error("HTTP error during APIM/OnBase interaction: %s", str(ex))

                response_text = None
                status_code = 502

                try:
                        response_text = ex.response.text
                        if ex.response.status_code:
                                status_code = ex.response.status_code
                except Exception:
                        response_text = "Unable to read HTTP response body."

                return _dtk_build_json_response(
                        payload={
                                "error": "HttpError",
                                "detail": str(ex),
                                "responseBody": response_text
                        },
                        status_code=status_code
                )

        except Exception as ex:
                logger.exception("Unhandled exception occurred.")

                return _dtk_build_json_response(
                        payload={
                                "error": "UnhandledException",
                                "detail": str(ex)
                        },
                        status_code=500
                )


def _dtk_load_config(logger: logging.Logger) -> Dict[str, str]:
        """
        ============================================================================================
        HELPER 2: LOAD CONFIG
        ============================================================================================

        REQUIRED:
                ONBASE_APIM_BASE_URL

        OPTIONAL:
                ONBASE_APIM_SUBSCRIPTION_KEY
        """

        onbase_apim_base_url = os.environ.get("ONBASE_APIM_BASE_URL")
        onbase_apim_subscription_key = os.environ.get("ONBASE_APIM_SUBSCRIPTION_KEY")

        if not onbase_apim_base_url:
                raise ValueError("Missing required environment variable: ONBASE_APIM_BASE_URL")

        config = {
                "onbaseApimBaseUrl": onbase_apim_base_url.rstrip("/"),
                "onbaseApimSubscriptionKey": onbase_apim_subscription_key
        }

        logger.info("Configuration loaded successfully.")

        return config


def _dtk_read_request_document_type_id(
        logger: logging.Logger,
        req: func.HttpRequest
) -> str:
        """
        ============================================================================================
        HELPER 3: READ REQUEST DOCUMENT TYPE ID
        ============================================================================================

        Reads and validates the single required query string parameter.

        Query string values always arrive as strings. This one stays a string -- see the
        REQUEST PARAMETERS note at the top of the file.
        """

        document_type_id_raw = req.params.get("documentTypeId")

        if not document_type_id_raw or not document_type_id_raw.strip():
                raise ValueError("Missing required query string parameter: documentTypeId")

        document_type_id = document_type_id_raw.strip()

        logger.info("Requested documentTypeId=%s", document_type_id)

        return document_type_id


def _dtk_build_apim_headers(
        logger: logging.Logger,
        config: Dict[str, str]
) -> Dict[str, str]:
        """
        ============================================================================================
        HELPER 4: BUILD APIM HEADERS
        ============================================================================================

        Builds the headers used when the function calls the APIM-managed OnBase endpoint.

        NOTE:
        We are NOT placing raw OnBase bearer logic here.
        APIM is handling that part in your environment.
        """

        headers = {
                "Accept": "application/json",
                "Content-Type": "application/json"
        }

        subscription_key = config.get("onbaseApimSubscriptionKey")

        if subscription_key:
                headers["Ocp-Apim-Subscription-Key"] = subscription_key

        logger.info("APIM headers built successfully.")

        return headers


def _dtk_get_document_type_keyword_groups(
        logger: logging.Logger,
        config: Dict[str, str],
        headers: Dict[str, str],
        document_type_id: str
) -> Dict[str, Any]:
        """
        ============================================================================================
        HELPER 5: GET DOCUMENT TYPE KEYWORD GROUPS
        ============================================================================================

        Calls:
                GET {ONBASE_APIM_BASE_URL}/document-types/{documentTypeId}/keyword-type-groups

        Returns the raw nested payload. Shaping happens in the next helper.

        A 404 from OnBase means EITHER the document type does not exist OR the RESTAPI account
        has no rights to it. OnBase does not distinguish between the two.
        """

        path = _DTK_KEYWORD_GROUPS_PATH.format(documentTypeId=document_type_id)

        url = f'{config["onbaseApimBaseUrl"]}{path}'

        logger.info("Retrieving keyword type groups through APIM. URL=%s", url)

        response = requests.get(
                url=url,
                headers=headers,
                timeout=120
        )

        response.raise_for_status()

        logger.info("Keyword type groups retrieved successfully.")

        return response.json()


def _dtk_map_keyword_groups_to_rows(
        logger: logging.Logger,
        keyword_groups_response: Dict[str, Any],
        document_type_id: str
) -> List[Dict[str, Any]]:
        """
        ============================================================================================
        HELPER 6: MAP KEYWORD GROUPS TO ROWS
        ============================================================================================

        Flattens the nested OnBase payload into one row per keyword type.

        Array position carries the display order configured on the document type. It is captured
        here as explicit index columns because position does not survive landing in a Lakehouse.

        The three keywordOptions id arrays are turned into per-row booleans so the behavior
        travels with the association rather than sitting in a side structure.
        """

        keyword_options = keyword_groups_response.get("keywordOptions") or {}

        required_for_archival = set(keyword_options.get("requiredForArchivalKeywordTypeIds") or [])
        required_for_retrieval = set(keyword_options.get("requiredForRetrievalKeywordTypeIds") or [])
        read_only = set(keyword_options.get("readOnlyKeywordTypeIds") or [])

        rows = []
        display_index = 0

        for group_index, group in enumerate(keyword_groups_response.get("items") or []):

                keyword_type_group_id = group.get("id")

                for keyword_index_in_group, keyword_type in enumerate(group.get("keywordTypes") or []):

                        keyword_type_id = keyword_type.get("id")

                        rows.append({
                                "documentTypeId": document_type_id,
                                "keywordTypeGroupId": keyword_type_group_id,
                                "keywordTypeId": keyword_type_id,
                                "groupIndex": group_index,
                                "keywordIndexInGroup": keyword_index_in_group,
                                "displayIndex": display_index,
                                "requiredForArchival": keyword_type_id in required_for_archival,
                                "requiredForRetrieval": keyword_type_id in required_for_retrieval,
                                "readOnly": keyword_type_id in read_only
                        })

                        display_index = display_index + 1

        logger.info(
                "Mapped %d keyword association rows for documentTypeId=%s",
                len(rows),
                document_type_id
        )

        return rows


def _dtk_build_json_response(
        payload: Dict[str, Any],
        status_code: int
) -> func.HttpResponse:
        """
        ============================================================================================
        HELPER 7: BUILD JSON RESPONSE
        ============================================================================================

        Standardizes the final JSON response.
        """

        return func.HttpResponse(
                json.dumps(payload, indent=4),
                status_code=status_code,
                mimetype="application/json"
        )