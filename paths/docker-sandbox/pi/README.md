# Pi Agent Kit for Docker Sandbox

1. Build and load the template (from repo root):
   ```
   docker build -t agent-factory/pi:latest ./paths/docker-sandbox/pi/
   docker image save agent-factory/pi:latest -o /tmp/pi.tar
   sbx template load /tmp/pi.tar
   ```
2. Set the credential: `sbx secret set -g local-inference`
3. Run: `sbx run --kit ./paths/docker-sandbox/pi pi`
