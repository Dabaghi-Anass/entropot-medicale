import React, { useContext, useState } from 'react'
import './SideBar.css'
import { Context } from '../../Context/Context';
const SideBar = () => {
    const [extended, setExtended] = useState(false);

    const { onSent, prevsPrompt, setRecentprompt, newChat } = useContext(Context);

    const onload = async (prompt) => {
        setRecentprompt(prompt)
        await onSent(prompt);
    }


    return (
        <div className="sidebar">
            <div className="top">
                <span onClick={() => { setExtended(!extended) }}><ion-icon name="menu-outline" style={{ color: "white" }}></ion-icon></span>
                <div className="chat" onClick={() => { newChat() }}>
                    <ion-icon name="add-outline" style={{ color: "white" }}></ion-icon>
                    {extended ? <p style={{ color: "white" }}>New Consultation</p> : null}
                </div>
                {extended ?
                    <div className="recent">
                        <p className="recent_title">Recent Consultations</p>
                        {prevsPrompt.map((item, index) => {
                            return (
                                <div className="recent_entry" key={index} onClick={() => { onload(item) }}>
                                    <ion-icon name="chatbubble-ellipses-outline" style={{ color: "#e3f2fd" }}></ion-icon>
                                    <p>{item.slice(0, 15)} ...</p>
                                </div>
                            )
                        })}


                    </div>
                    : null
                }


            </div>






            <div className="bottom">
                <hr style={{ color: "#e3f2fd", backgroundColor: "#e3f2fd", height: "1px", border: "none" }} />
                <div className="chatItem recent_entry">
                    <ion-icon name="help-circle-outline" style={{ color: "#e3f2fd" }} />
                    {extended ? <p style={{ color: "#e3f2fd" }}>Medical Help</p> : null}
                </div>

                <div className="chatItem recent_entry">
                    <ion-icon name="pulse-outline" style={{ color: "#e3f2fd" }} />
                    {extended ? <p style={{ color: "#e3f2fd" }}>Health Monitor</p> : null}
                </div>

                <div className="chatItem recent_entry">
                    <ion-icon name="settings-outline" style={{ color: "#e3f2fd" }} />
                    {extended ? <p style={{ color: "#e3f2fd" }}>Settings</p> : null}
                </div>
            </div>
        </div>
    )
}

export default SideBar