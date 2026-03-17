async function getUpcomingTasks() {
  // Aquí pegas el token largo que te dio el script anterior
  const token = ''; 
  
  // Endpoint principal para consumir los Web Services de Moodle
  const baseUrl = 'https://pev.surguanajuato.tecnm.mx/webservice/rest/server.php';
  
  // La función específica que queremos llamar
  const wsfunction = 'core_calendar_get_calendar_upcoming_view';
  
  // Le decimos a Moodle que queremos la respuesta en JSON (por defecto a veces manda XML)
  const format = 'json';

  const url = `${baseUrl}?wstoken=${token}&wsfunction=${wsfunction}&moodlewsrestformat=${format}`;

  try {
    console.log('Consultando tareas próximas...\n');
    const response = await fetch(url);
    const data = await response.json();

    // Moodle guarda las tareas dentro del arreglo "events"
    if (data.events && data.events.length > 0) {
      console.log('✅ Tareas encontradas:\n');
      
      data.events.forEach(tarea => {
        // Moodle maneja las fechas en formato Unix (segundos). Lo pasamos a milisegundos para JS.
        const fechaLimite = new Date(tarea.timestart * 1000).toLocaleString('es-MX');
        
        console.log(`📚 Materia: ${tarea.course.fullname}`);
        console.log(`📝 Tarea: ${tarea.name}`);
        console.log(`⏰ Vence: ${fechaLimite}`);
        console.log('-----------------------------------');
      });
    } else if (data.events && data.events.length === 0) {
      console.log('🎉 No tienes tareas próximas a vencer.');
    } else {
      console.log('⚠️ Hubo un error o el token ya expiró:');
      console.log(data);
    }
  } catch (error) {
    console.error('Error de red:', error);
  }
}

getUpcomingTasks();