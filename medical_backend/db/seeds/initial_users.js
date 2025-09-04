// db/seeds/initial_users.js
/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.seed = async function (knex) {
  // Deletes ALL existing entries in the 'users' table
  await knex('users').del();
  await knex('users').insert([
    {
      id: 'd034237d-1c3f-4e1b-8b0d-6e01d67e8c3b',
      name: 'New User',
      email: 'new.user@example.com',
      phone_number: '',
      image_url: 'https://placehold.co/100x100/CCCCCC/000000.png?text=NU',
    },
  ]);
};