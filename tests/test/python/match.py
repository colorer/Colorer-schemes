def http_status(code):
    match code:
        case 200 | 201:
            return "ok"
        case 404:
            return "missing"
        case _:
            return "other"
