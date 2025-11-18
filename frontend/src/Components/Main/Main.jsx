import React, { useContext } from 'react'
import './Main.css'
import { Context } from '../../Context/Context';
import star from '../../assets/sparkle.png'

const Main = () => {
    const { prevsPrompt, setPrevsPrompt, onSent, setRecentprompt, recentPrompt, showResult,
        loading, resultdata, input, setInput } = useContext(Context);



    return (
        <div className="main">
            <div className="nav">
                <p>Medical<b>AI</b> Assistant</p>
                <span><ion-icon name="person-outline" style={{ color: "#1e3a8a" }}></ion-icon></span>
            </div>
            <div className="main_container">
                {!showResult ?
                    <>
                        <div className="greet">
                            <p ><span>Hello, I'm your Medical<span className='AI'>AI</span> Assistant</span></p>
                            <p >How can I help you with your healthcare needs today?</p>
                        </div>
                        <div className="cards">
                            <div className="card">
                                <p>Find nearby hospitals and medical centers</p>
                                <ion-icon name="location-outline" style={{ color: "#16a085" }}></ion-icon>
                            </div>
                            <div className="card">
                                <p>Get information about medical symptoms and conditions</p>
                                <ion-icon name="medical-outline" style={{ color: "#1e3a8a" }}></ion-icon>
                            </div>
                            <div className="card">
                                <p>Schedule appointments and manage healthcare</p>
                                <ion-icon name="calendar-outline" style={{ color: "#16a085" }}></ion-icon>
                            </div>
                            <div className="card">
                                <p>Emergency contacts and first aid guidance</p>
                                <ion-icon name="heart-outline" style={{ color: "#dc2626" }}></ion-icon>
                            </div>
                        </div>
                    </>
                    :
                    <div className="result">
                        <div className="result_title">
                            <ion-icon name="person-outline" style={{ color: "#1e3a8a" }}></ion-icon>
                            <p>{recentPrompt}</p>
                        </div>
                        <div className="result_data">
                            <img src={star} />
                            {loading
                                ?
                                <div className="loader">
                                    <hr />
                                    <hr />
                                    <hr />
                                </div>
                                :
                                <p dangerouslySetInnerHTML={{ __html: resultdata }}></p>
                            }

                        </div>
                    </div>
                }


                <div className="main_bottom">
                    <div className="searchbox">
                        <input onChange={(e) => setInput(e.target.value)} value={input} type="text" placeholder='Ask about symptoms, medications, or health concerns...' />
                        <div className="icons">
                            <span onClick={() => { onSent() }}><ion-icon name="send" style={{ color: "#1e3a8a" }}></ion-icon></span>
                        </div>
                    </div>
                    <p className='bottom_info'>MedicalAI may provide general health information. Always consult with qualified healthcare professionals for medical advice.</p>
                </div>
            </div>
        </div>
    )
}

export default Main