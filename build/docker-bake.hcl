group "default" {
  targets = ["1_29_0_PHP81", "1_29_0_PHP82", "1_29_1_PHP81", "1_29_1_PHP82"]
}

target "build-dockerfile" {
  dockerfile = "Dockerfile"
}

target "build-platforms" {
  platforms = ["linux/amd64", "linux/armhf", "linux/aarch64"]
}

target "build-common" {
  pull = true
}

variable "REGISTRY_CACHE" {
  default = "docker.io/nlss/unit-php-cache"
}

######################
# Define the functions
######################

# Get the arguments for the build
function "get-args" {
  params = [unit_version, php_version]
  result = {
    UNIT_VERSION = unit_version
    PHP_VERSION = php_version
  }
}

# Get the cache-from configuration
function "get-cache-from" {
  params = [version]
  result = [
    "type=gha,scope=${version}_${BAKE_LOCAL_PLATFORM}",
    "type=registry,ref=${REGISTRY_CACHE}:${sha1("${version}-${BAKE_LOCAL_PLATFORM}")}"
  ]
}

# Get the cache-to configuration
function "get-cache-to" {
  params = [version]
  result = [
    "type=gha,mode=max,scope=${version}_${BAKE_LOCAL_PLATFORM}",
    "type=registry,mode=max,ref=${REGISTRY_CACHE}:${sha1("${version}-${BAKE_LOCAL_PLATFORM}")}"
  ]
}

# Get list of image tags and registries
# Takes a version and a list of extra versions to tag
# eg. get-tags("1.29.1", ["1.29", "latest"])
function "get-tags" {
  params = [version, extra_versions]
  result = concat(
    [
      "docker.io/nlss/unit-php:${version}"
    ],
    flatten([
      for extra_version in extra_versions : [
        "docker.io/nlss/unit-php:${extra_version}"
      ]
    ])
  )
}

##########################
# Define the build targets
##########################

target "1_29_0_PHP81" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("1.29.0-PHP8.1")
  cache-to   = get-cache-to("1.29.0-PHP8.1")
  tags       = get-tags("1.29.0-PHP8.1", [])
  args       = get-args("1.29.0", "8.1")
}

target "1_29_0_PHP82" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("1.29.0-PHP8.2")
  cache-to   = get-cache-to("1.29.0-PHP8.2")
  tags       = get-tags("1.29.0-PHP8.2", ["1.29.0"])
  args       = get-args("1.29.0", "8.2")
}

target "1_29_1_PHP81" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("1.29.1-PHP8.1")
  cache-to   = get-cache-to("1.29.1-PHP8.1")
  tags       = get-tags("1.29.1-PHP8.1", ["1.29-PHP8.1"])
  args       = get-args("1.29.1", "8.1")
}

target "1_29_1_PHP82" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("1.29.1-PHP8.2")
  cache-to   = get-cache-to("1.29.1-PHP8.2")
  tags       = get-tags("1.29.1-PHP8.2", ["1.29-PHP8.2", "1.29", "1.29.1", "latest"])
  args       = get-args("1.29.1", "8.2")
}