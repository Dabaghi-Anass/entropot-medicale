import NavBar from '../components/navbar';
import Conversation from './conversation';
import DoctorGif from '../assets/images/doctor.gif';
export default function ConversationPage() {
  return (
    <div className='conversation'>
      <NavBar theme='dark'></NavBar>
      <main className='chat-container'>
        <section className='robot-animation'>
          <img src={DoctorGif} alt='robot-animation' className='robot-gif' />
        </section>
        <Conversation />
      </main>
    </div>
  );
}
