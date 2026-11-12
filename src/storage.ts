import { GetObjectCommand, PutObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

let client: S3Client | null = null;

export function storageConfigured(): boolean {
  return Boolean(
    process.env.AWS_ENDPOINT_URL_S3 &&
      process.env.AWS_ACCESS_KEY_ID &&
      process.env.AWS_SECRET_ACCESS_KEY &&
      process.env.S3_BUCKET,
  );
}

export function getS3(): S3Client {
  if (client) return client;
  client = new S3Client({
    region: process.env.AWS_REGION || "us-east-2",
    endpoint: process.env.AWS_ENDPOINT_URL_S3,
    forcePathStyle: true,
    credentials: {
      accessKeyId: process.env.AWS_ACCESS_KEY_ID || "",
      secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || "",
    },
  });
  return client;
}

export function bucketName(): string {
  return process.env.S3_BUCKET || "actfiles";
}

export async function putObject(key: string, body: Buffer, contentType: string): Promise<void> {
  await getS3().send(
    new PutObjectCommand({
      Bucket: bucketName(),
      Key: key,
      Body: body,
      ContentType: contentType,
    }),
  );
}

export async function signedGet(key: string): Promise<string> {
  return getSignedUrl(
    getS3(),
    new GetObjectCommand({ Bucket: bucketName(), Key: key }),
    { expiresIn: 3600 },
  );
}
