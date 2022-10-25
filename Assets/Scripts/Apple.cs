using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class Apple : MonoBehaviour, ICollectible
{

    public static event HandleBookCollected OnAppleCollected;
    public delegate void HandleBookCollected(ItemData itemData);
    public ItemData appleData;

    public void Collect()
    {
        Destroy(gameObject);
        OnAppleCollected?.Invoke(appleData);
    }


}
