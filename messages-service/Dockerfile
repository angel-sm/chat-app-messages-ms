# Dockerfile
FROM public.ecr.aws/lambda/nodejs:20

WORKDIR ${LAMBDA_TASK_ROOT}

# Install esbuild for TypeScript compilation
RUN npm install -g esbuild

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --omit=dev

COPY . .

# Copy source code
COPY tsconfig.json ${LAMBDA_TASK_ROOT}/

# Build TypeScript code
RUN esbuild main.ts --bundle --platform=node --target=node20 --outfile=dist/main.js

# Set the CMD to your handler
CMD [ "dist/main.handler" ]