module.exports.handler = async (event) => {
  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      message: 'Node.js app deployed using Terraform, S3 and API Gateway.',
    }),
  }
}
