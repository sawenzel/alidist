package: curl
version: "1.0"
system_requirement_missing: "Please install Curl."
system_requirement: ".*"
system_requirement_check: "curl --version > /dev/null || [ $? -ne 127 ]"
---

