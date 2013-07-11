# If you have a very small app you may be able to
# increase this, but in general 3 workers seems to
# work best
worker_processes 2

# Load rails+github.git into the master before forking workers
# for super-fast worker spawn times
preload_app true

# Immediately restart any workers that
# haven't responded within 30 seconds
timeout 30

