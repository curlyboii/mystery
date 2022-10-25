using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class PauseMenu : MonoBehaviour
{
    public GameObject pauseMenuScreen;
    public GameObject controller;
    public GameObject pauseButton;
    public GameObject bookButton;
    public GameObject bookMenu;
    public GameObject inventory;
    public GameObject inventoryPanel;
    public void PauseGame()
    {
        Time.timeScale = 0;
        pauseMenuScreen.SetActive(true);
        controller.SetActive(false);
        pauseButton.SetActive(false);
        bookButton.SetActive(false);
        inventory.SetActive(false);
        inventoryPanel.SetActive(false);
    }

    public void ResumeGame()
    {
        Time.timeScale = 1;
        pauseMenuScreen.SetActive(false);
        controller.SetActive(true);
        pauseButton.SetActive(true);
        bookButton.SetActive(true);
        inventory.SetActive(true);
    }

    public void GoToMainMenu()
    {
        SceneManager.LoadScene("Menu");
        if (Time.timeScale == 0)
        {

            Time.timeScale = 1;

        }
    }
    public void Book()
    {
        Time.timeScale = 0;
        bookMenu.SetActive(true);
        bookButton.SetActive(false);
        controller.SetActive(false);
        pauseButton.SetActive(false);
        inventory.SetActive(false);
        inventoryPanel.SetActive(false);
    }
    public void CloseBook()
    {
        Time.timeScale = 1;
        bookMenu.SetActive(false);
        controller.SetActive(true);
        pauseButton.SetActive(true);
        bookButton.SetActive(true);
        inventory.SetActive(true);
    }
    public void Inventory()
    {
        if (inventoryPanel != null)
        {
            bool isActive = inventoryPanel.activeSelf;

            inventoryPanel.SetActive(!isActive);

        }
    }

}
