-- Inicialización de base de datos PostgreSQL para Keiko
-- Crea bases de datos separadas para cada microservicio

-- Base de datos para Identity Service
CREATE DATABASE identity_service;
CREATE USER identity_user WITH ENCRYPTED PASSWORD 'identity_password';
GRANT ALL PRIVILEGES ON DATABASE identity_service TO identity_user;

-- Base de datos para Learning Service  
CREATE DATABASE learning_service;
CREATE USER learning_user WITH ENCRYPTED PASSWORD 'learning_password';
GRANT ALL PRIVILEGES ON DATABASE learning_service TO learning_user;

-- Base de datos para Reputation Service
CREATE DATABASE reputation_service;
CREATE USER reputation_user WITH ENCRYPTED PASSWORD 'reputation_password';
GRANT ALL PRIVILEGES ON DATABASE reputation_service TO reputation_user;

-- Base de datos para Passport Service
CREATE DATABASE passport_service;
CREATE USER passport_user WITH ENCRYPTED PASSWORD 'passport_password';
GRANT ALL PRIVILEGES ON DATABASE passport_service TO passport_user;

-- Base de datos para Governance Service
CREATE DATABASE governance_service;
CREATE USER governance_user WITH ENCRYPTED PASSWORD 'governance_password';
GRANT ALL PRIVILEGES ON DATABASE governance_service TO governance_user;

-- Base de datos para Marketplace Service
CREATE DATABASE marketplace_service;
CREATE USER marketplace_user WITH ENCRYPTED PASSWORD 'marketplace_password';
GRANT ALL PRIVILEGES ON DATABASE marketplace_service TO marketplace_user;

-- Extensiones útiles
\c identity_service;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

\c learning_service;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

\c reputation_service;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

\c passport_service;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

\c governance_service;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

\c marketplace_service;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";