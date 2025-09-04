// medical_backend/server.js
require('dotenv').config({ path: './.env' }); // Load environment variables from .env file
const express = require('express');
const cors = require('cors'); // For handling CORS
const multer = require('multer'); // For handling file uploads
const path = require('path');
const knexConfig = require('./knexfile'); // Import Knex configuration
const knex = require('knex')(knexConfig.development); // Initialize Knex with development config

const app = express();
const port = process.env.PORT || 3000; // Use port from .env or default to 3000

// Middleware
app.use(cors()); // Enable CORS for all routes
app.use(express.json()); // Enable parsing of JSON request bodies

// Serve static files from uploads directory
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'Uploads/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ storage: storage });

// Test Database Connection (using Knex)
knex.raw('SELECT NOW()')
  .then((result) => {
    console.log('PostgreSQL connected successfully using Knex! Current time:', result.rows[0].now);
  })
  .catch((err) => {
    console.error('Error connecting to PostgreSQL using Knex:', err.stack);
    process.exit(1); // Exit if database connection fails
  });

// Simple UUID validation helper function
function isValidUUID(uuid) {
  const regex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  return regex.test(uuid);
}

// --- API Endpoints for User Management ---

// GET all users
app.get('/api/users', async (req, res) => {
  try {
    const users = await knex('users').select('id', 'name', 'email', 'phone_number', 'image_url');
    res.json(users);
  } catch (err) {
    console.error('Error fetching users:', err.stack);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET a single user by ID
app.get('/api/users/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const user = await knex('users').where({ id }).first();
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json(user);
  } catch (err) {
    console.error('Error fetching user:', err.stack);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// CREATE a new user
app.post('/api/users', async (req, res) => {
  const { name, email, phoneNumber, imageUrl } = req.body;
  try {
    const newUser = {
      name,
      email,
      phone_number: phoneNumber,
      image_url: imageUrl,
    };
    const [createdUser] = await knex('users').insert(newUser).returning('*');
    res.status(201).json(createdUser);
  } catch (err) {
    if (err.constraint === 'users_email_unique') {
      res.status(409).json({ error: 'A user with this email already exists.' });
    } else {
      console.error('Error creating user:', err.stack);
      res.status(500).json({ error: 'Internal server error' });
    }
  }
});

// UPDATE an existing user
app.put('/api/users/:id', async (req, res) => {
  const { id } = req.params;
  const { name, email, phoneNumber, imageUrl } = req.body;
  try {
    const updatedUser = {
      name,
      email,
      phone_number: phoneNumber,
      image_url: imageUrl,
      updated_at: knex.fn.now(),
    };
    const [user] = await knex('users').where({ id }).update(updatedUser).returning('*');
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json(user);
  } catch (err) {
    if (err.constraint === 'users_email_unique') {
      res.status(409).json({ error: 'Email already in use by another user.' });
    } else {
      console.error('Error updating user:', err.stack);
      res.status(500).json({ error: 'Internal server error' });
    }
  }
});

// DELETE a user
app.delete('/api/users/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const deleted = await knex('users').where({ id }).del();
    if (deleted === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.status(204).send(); // 204 No Content for successful deletion
  } catch (err) {
    console.error('Error deleting user:', err.stack);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// --- API Endpoints for Appointments ---

// GET user's appointments
app.get('/api/appointments/:userId', async (req, res) => {
  const { userId } = req.params;
  // New: Validate that the userId is a properly formatted UUID.
  if (!isValidUUID(userId)) {
    return res.status(400).json({ error: 'Invalid user ID format. Must be a valid UUID.' });
  }

  try {
    const appointments = await knex('appointments')
      .where({ user_id: userId })
      .join('doctors', 'appointments.doctor_id', '=', 'doctors.id')
      .select(
        'appointments.*',
        knex.raw('json_build_object(\'id\', doctors.id, \'name\', doctors.name, \'specialty\', doctors.specialty, \'imageUrl\', doctors.image_url, \'rating\', doctors.rating, \'experience\', doctors.experience, \'bio\', doctors.bio, \'availableTime\', doctors.available_time) as doctor')
      );
    res.json(appointments);
  } catch (err) {
    console.error('Error fetching appointments:', err.stack);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// CREATE a new appointment
app.post('/api/appointments', async (req, res) => {
  const { userId, doctorId, date, time, status } = req.body;
  try {
    const newAppointment = {
      user_id: userId,
      doctor_id: doctorId,
      appointment_date: date,
      appointment_time: time,
      status: status || 'Upcoming',
    };
    const [createdAppointment] = await knex('appointments')
      .insert(newAppointment)
      .returning('*');

    // Fetch the associated doctor to return a complete Appointment object
    const doctor = await knex('doctors').where({ id: createdAppointment.doctor_id }).first();
    if (!doctor) {
      return res.status(500).json({ error: 'Doctor not found for the new appointment' });
    }

    res.status(201).json({
      id: createdAppointment.id,
      date: createdAppointment.appointment_date,
      time: createdAppointment.appointment_time,
      status: createdAppointment.status,
      doctor: {
        id: doctor.id,
        name: doctor.name,
        specialty: doctor.specialty,
        imageUrl: doctor.image_url,
        rating: doctor.rating,
        experience: doctor.experience,
        bio: doctor.bio,
        availableTime: doctor.available_time,
      },
    });
  } catch (err) {
    console.error('Error creating appointment:', err.stack);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// UPDATE an existing appointment
app.put('/api/appointments/:id', async (req, res) => {
  const { id } = req.params;
  const { date, time, status } = req.body;
  try {
    const updatedAppointmentData = {
      appointment_date: date,
      appointment_time: time,
      status,
      updated_at: knex.fn.now(),
    };

    const [updatedAppointment] = await knex('appointments')
      .where({ id })
      .update(updatedAppointmentData)
      .returning('*');

    if (!updatedAppointment) {
      return res.status(404).json({ error: 'Appointment not found' });
    }

    // Fetch the associated doctor to return a complete Appointment object
    const doctor = await knex('doctors').where({ id: updatedAppointment.doctor_id }).first();
    if (!doctor) {
      return res.status(500).json({ error: 'Doctor not found for the updated appointment' });
    }

    res.json({
      id: updatedAppointment.id,
      date: updatedAppointment.appointment_date,
      time: updatedAppointment.appointment_time,
      status: updatedAppointment.status,
      doctor: {
        id: doctor.id,
        name: doctor.name,
        specialty: doctor.specialty,
        imageUrl: doctor.image_url,
        rating: doctor.rating,
        experience: doctor.experience,
        bio: doctor.bio,
        availableTime: doctor.available_time,
      }
    });
  } catch (err) {
    console.error('Error updating appointment:', err.stack);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// DELETE an appointment
app.delete('/api/appointments/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const deletedRows = await knex('appointments').where({ id }).del();
    if (deletedRows === 0) {
      return res.status(404).json({ error: 'Appointment not found' });
    }
    res.status(204).send();
  } catch (err) {
    console.error('Error deleting appointment:', err.stack);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// --- API Endpoints for Doctors ---

// GET all doctors with an optional specialty filter
app.get('/api/doctors', async (req, res) => {
  const { specialty } = req.query;
  try {
    let query = knex('doctors');
    if (specialty) {
      query = query.where({ specialty });
    }
    const doctors = await query.select('*');
    res.json(doctors);
  } catch (err) {
    console.error('Error fetching doctors:', err.stack);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET a single doctor by ID
app.get('/api/doctors/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const doctor = await knex('doctors').where({ id }).first();
    if (!doctor) {
      return res.status(404).json({ error: 'Doctor not found' });
    }
    res.json(doctor);
  } catch (err) {
    console.error('Error fetching doctor:', err.stack);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET all specialties
app.get('/api/specialties', async (req, res) => {
  try {
    const specialties = await knex('doctors').distinct('specialty').pluck('specialty');
    res.json(specialties);
  } catch (err) {
    console.error('Error fetching specialties:', err.stack);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// --- API Endpoint for File Upload ---

// POST upload image
app.post('/api/upload', upload.single('image'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }
    const imageUrl = `http://localhost:3000/uploads/${req.file.filename}`;
    res.json({ imageUrl });
  } catch (err) {
    console.error('Error uploading file:', err.stack);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Start the server
app.listen(port, '0.0.0.0', () => {
  console.log(`Server is running on http://0.0.0.0:${port}`);
  console.log(`Accessible from emulator/device at http://192.168.1.5:${port}`);
});
