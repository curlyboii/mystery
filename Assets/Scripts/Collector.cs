using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Collector : MonoBehaviour
{

    /*   ICollectible collectible = collision.GetComponent<ICollectible>();
           if (collectible != null)
           {

               collectible.Collect();

           }
    */

    /*  private void OnTriggerEnter(Collider collider)
      {
              ICollectible collectible = collider.GetComponent<ICollectible>();
              if (collectible != null)
              {

                  collectible.Collect();
                  Destroy(gameObject);

              }
      }
    

    private void OnTriggerEnter2D(Collider2D collision)
    {
        ICollectible collectible = collision.GetComponent<ICollectible>();
        if (collectible != null)
        {

            collectible.Collect();

        }
    }


    */
    private void OnTriggerEnter(Collider collider)
    {
        ICollectible collectible = collider.GetComponent<ICollectible>();
        if (collectible != null)
        {

            collectible.Collect();

        }
    }
}
