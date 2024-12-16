# Culinary Code Mobile Application

Welcome to the repository for our mobile application. We are using the Flutter framework developed by Google.

## Development

We have implemented a method to use a less secure connection to Keycloak to simplify development. This is not recommended for production. To enable this, set the environment variable `DEVELOPMENT_MODE` to `true`. This will enable the app to use the web-based device preview package, which will allow requests to Keycloak over HTTP. This is not recommended for production and is only meant for development purposes.

If you choose to develop only on the frontend, then we provide a Docker container that will run the backend server. This is useful if you do not have the backend server running locally. To run the backend server, run the following command:

```bash
TODO: Add command to run backend server
```

## Environment variables

The environment variables are set in the `.env` file. The following variables are required:

- `KEYCLOAK_BASE_URL` - The URL of the Keycloak server
- `KEYCLOAK_CLIENT_ID` - The client ID of the Keycloak server
- `KEYCLOAK_REALM` - The realm of the Keycloak server
- `BACKEND_BASE_URL` - The URL of the backend server
- `DEVELOPMENT_MODE` - Whether to use the web-based device preview package

## Getting Started

Read our roadmap on the project wiki to understand the current state of the project and what we are working on. If you are interested in contributing, please read our contribution guidelines. If you have any questions, please create an issue.

## Installation
> flutter pub get

## Start Application
> flutter run
