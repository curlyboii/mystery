using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class Book : MonoBehaviour, ICollectible
{
    public static event HandleBookCollected OnBookCollected;
    public delegate void HandleBookCollected(ItemData itemData);
    public ItemData bookData;

    public void Collect()
    {
        
        Destroy(gameObject);
        OnBookCollected?.Invoke(bookData);
        
       
    }
}
