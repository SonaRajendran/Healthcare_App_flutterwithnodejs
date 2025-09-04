/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.up = function(knex) {
  return knex.schema.createTable('appointments', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()')); // UUID for appointment ID
    table.uuid('user_id').references('id').inTable('users').onDelete('CASCADE').notNullable(); // Foreign key to users table
    table.uuid('doctor_id').references('id').inTable('doctors').onDelete('CASCADE').notNullable(); // Foreign key to doctors table
    table.date('appointment_date').notNullable();
    table.string('appointment_time').notNullable(); // Store as string (e.g., "10:00 AM")
    table.string('status').notNullable().defaultTo('Upcoming'); // e.g., 'Upcoming', 'Completed', 'Cancelled'
    table.timestamp('created_at').defaultTo(knex.fn.now());
    table.timestamp('updated_at').defaultTo(knex.fn.now());
  });
};

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.down = function(knex) {
  return knex.schema.dropTable('appointments');
};
