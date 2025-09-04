// medical_backend/create_db.js
require('dotenv').config({ path: './.env' }); // Load environment variables from .env

const { Client } = require('pg');

async function createDatabase() {
  // We need to connect to a default administrative database (like 'postgres')
  // to create a new database. Ensure 'postgres' user has CREATE DATABASE privileges.
  const adminClient = new Client({
    user: 'postgres', // Using the PostgreSQL superuser
    host: 'localhost', // Your PostgreSQL host
    database: 'postgres', // Connecting to a default database to perform creation
    password: process.env.PG_SUPERUSER_PASSWORD, // FIX: Use explicit PG_SUPERUSER_PASSWORD from .env
    port: 5432, // Your PostgreSQL port
  });

  try {
    await adminClient.connect();
    console.log('Connected to PostgreSQL administrative database for creation check.');

    const dbName = 'healthcare_db'; // The database name we want to create

    // Check if the database already exists
    const res = await adminClient.query(
      `SELECT 1 FROM pg_database WHERE datname = $1`,
      [dbName]
    );

    if (res.rowCount === 0) {
      // Database does not exist, create it
      // IMPORTANT: CREATE DATABASE does not support parameterized queries.
      // We are interpolating a trusted constant (dbName) so this is safe.
      await adminClient.query(`CREATE DATABASE "${dbName}"`);
      console.log(`Database "${dbName}" created successfully.`);
    } else {
      console.log(`Database "${dbName}" already exists. No action needed.`);
    }

  } catch (err) {
    console.error('Error during database creation process:', err.stack);
    // Provide more specific feedback for common errors
    if (err.message.includes('password authentication failed')) {
      console.error('Authentication failed. Double-check the "postgres" user password in your .env file or PostgreSQL settings. Make sure PG_SUPERUSER_PASSWORD is correct.');
    } else if (err.message.includes('role "postgres" does not exist')) {
      console.error('The specified PostgreSQL user "postgres" does not exist.');
    } else if (err.message.includes('permission denied to create database')) {
      console.error('User "postgres" does not have sufficient privileges to create databases.');
    }
  } finally {
    await adminClient.end(); // Always close the connection
    console.log('PostgreSQL administrative connection closed.');
  }
}

createDatabase();
