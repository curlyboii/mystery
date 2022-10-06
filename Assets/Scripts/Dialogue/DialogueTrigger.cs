using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DialogueTrigger : MonoBehaviour
{

    [Header("Visual Cue")]
    [SerializeField] private GameObject visualCue;

    [Header("Ink JSON")]
    [SerializeField] private TextAsset inkJSON;

    private bool playerInRange;

    private void Awake()
    {
        playerInRange = false;
        visualCue.SetActive(false);
    }

    private void Update()
    {
        if (playerInRange && !DialogueManager.GetInstance().dialogIsPlaying)
        {
            visualCue.SetActive(true);
            if (Input.GetKeyDown(KeyCode.Mouse0))
            {
                DialogueManager.GetInstance().EnterDialogueMode(inkJSON);
            }
        }

        else
        { 
            
            visualCue.SetActive(false); 
        
        }
    }


    private void OnTriggerEnter(Collider colider)
    {

        if (colider.gameObject.tag == "Player")
        {

            playerInRange = true;


        }
        
    }

    private void OnTriggerExit(Collider colider)
    {

        if (colider.gameObject.tag == "Player")
        {

            playerInRange = false;

        }
    }
}
