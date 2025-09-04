/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.up = function(knex) {
  return knex.schema.createTable('users', function(table) {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()')); // UUID as primary key, auto-generated
    table.string('name').notNullable();
    table.string('email').unique().notNullable(); // Email must be unique
    table.string('phone_number');
    table.string('image_url');
    table.timestamps(true, true); // created_at and updated_at columns
  });
};

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.down = function(knex) {
  return knex.schema.dropTable('users');
};
