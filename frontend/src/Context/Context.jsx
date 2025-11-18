import { createContext, useState } from "react";

export const Context = createContext();

const ContextProvider = (props) => {

    const delayPara = (index, nextword) => {
        setTimeout(function () {
            setresultData(prev => prev + nextword);
        }, 75 * index);
    }

    const newChat = () => {
        setLoading(false);
        setShowResult(false);
    }

    const onSent = async (prompt) => {
        setresultData("");
        setLoading(true);
        setShowResult(true);
        let response;

        if (prompt !== undefined) {
            response = "This is a demo response for: " + prompt;
            setRecentprompt(prompt);
        } else {
            setPrevsPrompt(prev => [...prev, input])
            setRecentprompt(input);
            response = "This is a demo response for: " + input;
        }

        let responseArray = response.split("**");
        let newResponse = "";
        for (let i = 0; i < responseArray.length; i++) {
            if (i === 0 || i % 2 !== 1) {
                newResponse += responseArray[i];
            } else {
                newResponse += "<b>" + responseArray[i] + "</b>";
            }
        }
        let newResponse2 = newResponse.split("*").join("</br>");
        let newResponseArray = newResponse2.split(" ");
        for (let i = 0; i < newResponseArray.length; i++) {
            let nextword = newResponseArray[i];
            if (nextword === "Google." || nextword === "Google," || nextword === "Google" || nextword === "Google:" || nextword == "Google**" || nextword == "جوجل.") {
                nextword = "elhoussine";
            }
            delayPara(i, nextword + " ");
        }

        setLoading(false);
        setInput("");
    }

    const [input, setInput] = useState('');
    const [recentPrompt, setRecentprompt] = useState('');
    const [prevsPrompt, setPrevsPrompt] = useState([]);
    const [showResult, setShowResult] = useState(false);
    const [loading, setLoading] = useState(false);
    const [resultdata, setresultData] = useState('');

    const contextvalue = {
        prevsPrompt,
        setPrevsPrompt,
        onSent,
        setRecentprompt,
        recentPrompt,
        showResult,
        loading,
        resultdata,
        input,
        setInput,
        newChat
    }

    return (
        <Context.Provider value={contextvalue}>
            {props.children}
        </Context.Provider>
    )
}

export default ContextProvider;