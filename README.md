# Cloud Resume Project

## Overview
This project hosts my personal resume as a static website on AWS, managed entirely with Terraform and deployed via GitHub Actions.

- **Static resume website** hosted on **S3** + **CloudFront**  
- **Visitor counter** backed by **API Gateway** → **Lambda** → **DynamoDB**  
- **Remote state** stored in **S3** with **DynamoDB** locking 

## Architecture Diagram
<!-- Embed your draw.io diagram below -->
![Architecture Diagram](cloud-resume-diagram.drawio.png)