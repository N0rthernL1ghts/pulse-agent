group "default" {
  targets = [
    "4_24_0",
  ]
}

target "build-dockerfile" {
  dockerfile = "Dockerfile"
}

target "build-platforms" {
  platforms = ["linux/amd64", "linux/aarch64"]
}

target "build-common" {
  pull = true
}

variable "REGISTRY_CACHE" {
  default = "ghcr.io/n0rthernl1ghts/pulse-agent-cache"
}

######################
# Define the functions
######################

# Get the arguments for the build
function "get-args" {
  params = [pulse_version]
  result = {
    PULSE_VERSION = pulse_version
  }
}

# Get the cache-from configuration
function "get-cache-from" {
  params = [version]
  result = [
    "type=registry,ref=${REGISTRY_CACHE}:${sha1("${version}-${BAKE_LOCAL_PLATFORM}")}"
  ]
}

# Get the cache-to configuration
function "get-cache-to" {
  params = [version]
  result = [
    "type=registry,mode=max,ref=${REGISTRY_CACHE}:${sha1("${version}-${BAKE_LOCAL_PLATFORM}")}"
  ]
}

# Get list of image tags and registries
# Takes a version and a list of extra versions to tag
# eg. get-tags("4.24.0", ["4.24", "latest"])
function "get-tags" {
  params = [version, extra_versions]
  result = concat(
    [
      "ghcr.io/n0rthernl1ghts/pulse-agent:${version}"
    ],
    flatten([
      for extra_version in extra_versions : [
        "ghcr.io/n0rthernl1ghts/pulse-agent:${extra_version}"
      ]
    ])
  )
}

##########################
# Define the build targets
##########################

target "4_24_0" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("4.24.0")
  cache-to   = get-cache-to("4.24.0")
  tags       = get-tags("4.24.0", ["4", "4.24", "latest"])
  args       = get-args("4.24.0")
}