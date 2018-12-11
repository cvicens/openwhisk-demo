// Dummy answer...
const DUMMY_EVENT = {
  id: 1,
  title: "Tech Lab: Application Development in a containerized world",
  subtitle: "A practical view",
  city: "Lisbon"
};

const DUMMY_SLOTS = [
  {
      id: 1,
      title: "Registration and morning coffee",
      time: "09:45"
  },
  {
      id: 2,
      title: "Trends in Application Development",
      time: "10:30"
  },
  {
      id: 3,
      title: "Coffee break",
      time: "10:30"
  },
  {
      id: 4,
      title: "Scared of a growing number of microservices?",
      time: "11:00"
  },
  {
      id: 5,
      title: "Modern event-driven applications: Kafka on OpenShift",
      time: "11:20"
  },
  {
      id: 6,
      title: "Demo",
      time: "11:40"
  }
];

let _response = {
  response: {
    shouldEndSession: false,
    outputSpeech: {
      type: "PlainText",
      text: null
    }
  },
  version: "1.0"
};

function main(params) {
    const request = params.request;
    const session = params.session;
    console.log('request: ', JSON.stringify(request));
    console.log('session: ', JSON.stringify(session));
    if (!request || !request.type || !request.intent || !request.intent.name) {
      _response.response.outputSpeech.text = 'Wrong intent or unknow error';
      _response.response.shouldEndSession = true;
      return _response;
    }

    const intent = request.intent;
    const type = request.type;

    if (type !== 'IntentRequest') {
      return null;
    }

    switch (intent.name) {
      case 'ListEvents':
        return listEvents(intent);

      case 'WhatsNext':
        return whatsNext(session);

      case 'WhatsNow':
        return whatsNow(session);
    
      default:
        _response.response.outputSpeech.text = "Intent not supported yet or unknow error";
        _response.response.shouldEndSession = true;
        return _response;
    }
}

function listEvents(intent) {
  console.log('_listEvents!!!');
  console.log(JSON.stringify(intent));
  if (!intent.slots || !intent.slots.city || !intent.slots.city.value) {
    _response.response.outputSpeech.text = "Wrong parameters or unknow error";
    _response.response.shouldEndSession = true;
    return _response;
  }

  const city = intent.slots.city.value || "Ibernia";

  // Only one event is possible per city and date
  const event = DUMMY_EVENT;

  _response.response.outputSpeech.text = event.title + ". " + event.subtitle + ". I'm happy.";
  _response.response.shouldEndSession = false,
  _response.sessionAttributes = {
    eventId: event.id
  }

  return _response;
}

function whatsNext (session) {
  if (!session) {
    _response.response.outputSpeech.text = "Wrong parameters or unknow error";
    _response.response.shouldEndSession = false;
    return _response;
  }

  const eventId = session.attributes.eventId;
  console.log('eventId', eventId)

  const slots = DUMMY_SLOTS;

  const next = slots[2];

  _response.response.outputSpeech.text = "The next slot for event " + eventId +  " is titled, " + next.title; // + " at " + next.time;
  _response.sessionAttributes = session.attributes || {};
  _response.sessionAttributes.next = next;

  return _response;
}

function whatsNow (session) {
  if (!session) {
    _response.response.outputSpeech.text = "Wrong parameters or unknow error";
    _response.response.shouldEndSession = true;
    return _response;
  }

  const eventId = session.attributes.eventId;
  console.log('eventId', eventId)

  const slots = DUMMY_SLOTS;

  const now = slots[1];

  _response.response.outputSpeech.text = "The current slot for event " + eventId +  " is titled, " + now.title; // + " at " + now.time;
  _response.sessionAttributes = session.attributes || {};
  _response.sessionAttributes.now = now;

  return _response;
}