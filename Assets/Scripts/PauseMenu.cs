using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class PauseMenu : MonoBehaviour
{
    public GameObject pauseMenuScreen;
    public GameObject controller;
    public GameObject pauseButton;
    public void PauseGame()
    {
        Time.timeScale = 0;
        pauseMenuScreen.SetActive(true);
        controller.SetActive(false);
        pauseButton.SetActive(false);
    }

    public void ResumeGame()
    {
        Time.timeScale = 1;
        pauseMenuScreen.SetActive(false);
        controller.SetActive(true);
        pauseButton.SetActive(true);
    }

    public void GoToMainMenu()
    {
        SceneManager.LoadScene("Menu");
        if (Time.timeScale == 0)
        {

            Time.timeScale = 1;

        }
    }
}
