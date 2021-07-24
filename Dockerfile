# FROM someok/aws-cli-v2:latest
FROM amazon/aws-cli:latest

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
# CMD ["bash"]
