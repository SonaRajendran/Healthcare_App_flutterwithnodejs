/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.seed = async function(knex) {
  // Deletes ALL existing entries
  await knex('doctors').del()
  await knex('doctors').insert([
    {
      id: '12345678-1234-1234-1234-123456789abc',
      name: 'Dr. Sarah Johnson',
      specialty: 'Cardiologist',
      image_url: 'https://placehold.co/100x100/4CAF50/FFFFFF?text=SJ',
      rating: 4.8,
      experience: '10 years',
      bio: 'Dr. Johnson is a highly experienced cardiologist dedicated to heart health.',
      available_time: 'Mon, Wed, Fri (9 AM - 5 PM)',
    },
    {
      id: '22345678-2234-2234-2234-223456789abc',
      name: 'Dr. Michael Lee',
      specialty: 'Pediatrician',
      image_url: 'https://placehold.co/100x100/8BC34A/FFFFFF?text=ML',
      rating: 4.5,
      experience: '8 years',
      bio: 'Dr. Lee specializes in pediatric care, ensuring the well-being of children.',
      available_time: 'Tue, Thu (10 AM - 6 PM)',
    },
    {
      id: '32345678-3234-3234-3234-323456789abc',
      name: 'Dr. Emily Chen',
      specialty: 'Dermatologist',
      image_url: 'https://placehold.co/100x100/66BB6A/FFFFFF?text=EC',
      rating: 4.9,
      experience: '12 years',
      bio: 'Dr. Chen provides expert care for skin conditions and cosmetic treatments.',
      available_time: 'Mon, Tue, Wed (11 AM - 7 PM)',
    },
    {
      id: '42345678-4234-4234-4234-423456789abc',
      name: 'Dr. David Williams',
      specialty: 'Neurologist',
      image_url: 'https://placehold.co/100x100/2196F3/FFFFFF?text=DW',
      rating: 4.7,
      experience: '15 years',
      bio: 'Dr. Williams is a leading neurologist with a focus on a wide range of neurological disorders.',
      available_time: 'Fri (9 AM - 3 PM)',
    },
    {
      id: '52345678-5234-5234-5234-523456789abc',
      name: 'Dr. Jessica Brown',
      specialty: 'Ophthalmologist',
      image_url: 'https://placehold.co/100x100/3F51B5/FFFFFF?text=JB',
      rating: 4.6,
      experience: '7 years',
      bio: "Dr. Brown specializes in eye and vision care, committed to preserving her patients' sight.",
      available_time: 'Thu, Fri (8 AM - 4 PM)',
    },
    {
      id: '62345678-6234-6234-6234-623456789abc',
      name: 'Dr. Robert Green',
      specialty: 'Orthopedic Surgeon',
      image_url: 'https://placehold.co/100x100/E91E63/FFFFFF?text=RG',
      rating: 4.9,
      experience: '20 years',
      bio: 'Dr. Green is an expert orthopedic surgeon specializing in joint replacements and sports injuries.',
      available_time: 'Mon, Tue (9 AM - 6 PM)',
    },
    {
      id: '72345678-7234-7234-7234-723456789abc',
      name: 'Dr. Laura Adams',
      specialty: 'Psychiatrist',
      image_url: 'https://placehold.co/100x100/9C27B0/FFFFFF?text=LA',
      rating: 4.4,
      experience: '9 years',
      bio: 'Dr. Adams provides compassionate psychiatric care for a variety of mental health conditions.',
      available_time: 'Wed, Thu (12 PM - 8 PM)',
    }
  ]);
};
