#!/usr/bin/env node
/**
 * Set Railway env vars via GraphQL API.
 * Uses RAILWAY_TOKEN, RAILWAY_PROJECT_ID, RAILWAY_ENVIRONMENT_ID from .env (or eggy/.env).
 * Run: node scripts/railway-set-vars.js
 *
 * If you get "Not Authorized", set variables manually in Railway → Variables.
 * Generate admin password: node scripts/generate-admin-password.js
 */
require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });
require('dotenv').config({ path: require('path').join(__dirname, '../.env') });

const TOKEN = process.env.RAILWAY_TOKEN;
const PROJECT_ID = process.env.RAILWAY_PROJECT_ID;
const ENV_ID = process.env.RAILWAY_ENVIRONMENT_ID;

const ENDPOINT = 'https://backboard.railway.com/graphql/v2';

if (!TOKEN || !PROJECT_ID || !ENV_ID) {
  console.error('Missing RAILWAY_TOKEN, RAILWAY_PROJECT_ID, or RAILWAY_ENVIRONMENT_ID');
  process.exit(1);
}

// Generate secure admin password if not set
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || require('crypto').randomBytes(12).toString('base64url');

async function graphql(op, vars = {}) {
  const res = await fetch(ENDPOINT, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${TOKEN}`,
    },
    body: JSON.stringify({ query: op, variables: vars }),
  });
  const json = await res.json();
  if (json.errors) throw new Error(json.errors.map((e) => e.message).join('; '));
  return json.data;
}

async function getServiceId() {
  const data = await graphql(`
    query($id: String!) {
      project(id: $id) {
        services {
          edges {
            node {
              id
              name
            }
          }
        }
      }
    }
  `, { id: PROJECT_ID });
  const edges = data?.project?.services?.edges || [];
  const serviceId = edges[0]?.node?.id;
  if (!serviceId) throw new Error('No service found in project');
  return serviceId;
}

async function main() {
  const serviceId = await getServiceId();
  const appUrl = process.env.APP_URL || 'https://propease.up.railway.app';

  const variables = {
    APP_URL: appUrl,
    ADMIN_PASSWORD: ADMIN_PASSWORD,
    BREVO_SMTP_HOST: process.env.BREVO_SMTP_HOST || 'smtp-relay.brevo.com',
    BREVO_SMTP_PORT: process.env.BREVO_SMTP_PORT || '587',
    BREVO_SMTP_USER: process.env.BREVO_SMTP_USER || '',
    BREVO_SMTP_PASS: process.env.BREVO_SMTP_PASS || '',
    BREVO_FROM_EMAIL: process.env.BREVO_FROM_EMAIL || 'naijaaiacademy@gmail.com',
    BREVO_FROM_NAME: process.env.BREVO_FROM_NAME || 'Property Ease Manager',
    LANDLORD_EMAIL: process.env.LANDLORD_EMAIL || 'naijaaiacademy@gmail.com',
  };
  // Only include vars that have values
  const varsToSet = {};
  for (const [k, v] of Object.entries(variables)) {
    if (v != null && v !== '') varsToSet[k] = String(v);
  }

  await graphql(`
    mutation($input: VariableCollectionUpsertInput!) {
      variableCollectionUpsert(input: $input)
    }
  `, {
    input: {
      projectId: PROJECT_ID,
      environmentId: ENV_ID,
      serviceId,
      variables: varsToSet,
      replace: false,
    },
  });

  console.log('Railway variables set successfully.');
  console.log('\n--- Your landlord admin password (save this!) ---');
  console.log(ADMIN_PASSWORD);
  console.log('--------------------------------------------------');
}

main().catch((e) => {
  console.error(e.message);
  process.exit(1);
});
