using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using Ink.Runtime;

public class DialogueManager : MonoBehaviour
{

    [Header("Dialogue UI")]
    [SerializeField] private GameObject dialoguePanel;
    [SerializeField] private TextMeshProUGUI dialogueText;


    private Story currentStory;

    public bool dialogIsPlaying { get; private set; }

    private static DialogueManager instance;

    private void Awake()
    {
        if (instance != null)
        {

            Debug.LogWarning("Found more than one Dialogue Manager is this scene");
        
        }

        instance = this;
    }

    public static DialogueManager GetInstance()
    {

        return instance;
    
    }

    private void Start()
    {
        dialogIsPlaying = false;
        dialoguePanel.SetActive(false);
    }

    private void Update()
    {
        if (!dialogIsPlaying)
        {

            return;
        
        }

        if (Input.GetKeyDown(KeyCode.Mouse1))
        {

            ContinueStory();

        }
    }

    public void EnterDialogueMode(TextAsset inkJSON)
    {

        currentStory = new Story(inkJSON.text);
        dialogIsPlaying = true;
        dialoguePanel.SetActive(true);

        ContinueStory();
    
    }

    private void ExitDialogueMode()
    {

        dialogIsPlaying = false;
        dialoguePanel.SetActive(false);
        dialogueText.text = "";
    
    }

    private void ContinueStory()
    {

        if (currentStory.canContinue)
        {

            dialogueText.text = currentStory.Continue();

        }
        else
        {

            ExitDialogueMode();

        }


    }


}
