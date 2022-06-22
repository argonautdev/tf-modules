# AWS CloudFront Terraform module

Terraform module Allows to create a distribution with S3 Origin

## Module Allows you to enable following features
```
   StandardLog/Accesslogs:, 
    When enabled following resources would be created and managed by module itself.
       1. Logging Bucket with ACLs
       2. KMS Key
       3. KMS Policy which allows cloudfront to publish logs to encrypted bucket.
   
   AlternativeDomain:
    1. It allows to access cloudfront with your dns name rather than cloudfront's dns name
    IMP Note:
       Ref: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cnames-and-https-requirements.html 
       To use a certificate in AWS Certificate Manager (ACM) to require HTTPS between viewers and CloudFront, make sure you request (or import) the certificate in the US East (N. Virginia) Region (us-east-1).
   
   Create distibution with NewBucket/Existing Bucket
   
   Route53 entries
       
```