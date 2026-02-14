#!/usr/bin/env bash
set -euo pipefail

# Runs integration tests for the module.
# Spring Loaded is only used on legacy JDKs where it is still viable.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

springloadedfile="${HOME}/.m2/repository/org/springframework/springloaded/1.2.3.RELEASE/springloaded-1.2.3.RELEASE.jar"

java_version_string="$(java -version 2>&1 | awk -F '"' '/version/ {print $2; exit}')"
java_major="$(echo "$java_version_string" | awk -F. '{if ($1=="1") print $2; else print $1}')"

maven_cmd=(mvn integration-test)

if ! command -v docker >/dev/null 2>&1; then
	echo "Docker non détecté: exécution du build Maven sans tests d'intégration."
	maven_cmd=(mvn package -DskipTests)
elif mvn -q help:all-profiles | grep -q "amp-to-war"; then
	maven_cmd+=("-Pamp-to-war")
fi

if [[ "$java_major" =~ ^[0-9]+$ ]] && [ "$java_major" -lt 13 ]; then
	if [ ! -f "$springloadedfile" ]; then
		mvn -q dependency:get -Dartifact=org.springframework:springloaded:1.2.3.RELEASE
	fi

	if [ -f "$springloadedfile" ]; then
		MAVEN_OPTS="-javaagent:$springloadedfile -noverify -Xms256m -Xmx2G" "${maven_cmd[@]}"
		exit $?
	fi
fi

MAVEN_OPTS="-Xms256m -Xmx2G" "${maven_cmd[@]}"
