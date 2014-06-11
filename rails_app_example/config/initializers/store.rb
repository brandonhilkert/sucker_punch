STORE = []
CRASHES = []

SuckerPunch.exception_handler { |ex| CRASHES << ex }
