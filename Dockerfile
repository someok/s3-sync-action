FROM someok/aws-cli-v2:v2

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
# CMD ["bash"]
