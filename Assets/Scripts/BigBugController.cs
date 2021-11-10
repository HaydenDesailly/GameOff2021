using System.Linq;
using UnityEngine;

public class BigBugController : MonoBehaviour
{
    BigBugManager.Node targetNode = null;

    private void Start()
    {
        targetNode = BigBugManager.Instance.Nodes.Where(n => Vector3.Distance(n.Point, PlayerManager.Instance.Player.transform.position) < 10f).FirstOrDefault();
    }

    private void Update()
    {
        var playerPosition = PlayerManager.Instance.Player.transform.position;

        if (targetNode != null)
        {
            if (Vector3.Distance(transform.position, targetNode.Point) > 0.1f)
            {
                //keep heading towards targetNode
                transform.position += (targetNode.Point - transform.position).normalized * Time.deltaTime * 5f;
            }
            else
            {
                //find next targetNode in player direction
                var nextNode = targetNode;
                foreach (var node in targetNode.Children)
                {
                    if (Vector3.Distance(node.Point, playerPosition) < Vector3.Distance(transform.position, playerPosition))
                    {
                        nextNode = node;
                        break;
                    }
                }

                targetNode = nextNode;
                transform.rotation = Quaternion.FromToRotation(targetNode.Point, targetNode.Normal);
            }
        }
    }

    private void FixedUpdate()
    {
        if (targetNode != null)
        {
            foreach (var child in targetNode.Children)
            {
                Debug.DrawLine(transform.position, child.Point, Color.red, 0.025f);
            }
        }
    }
}
