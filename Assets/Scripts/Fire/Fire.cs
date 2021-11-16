using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class Fire : MonoBehaviour {
    public System.Action onDeath;
    public ParticleSystem Particles;
    public Projector FireProjector;
    public Light FireLight;

    public float LifeTime = 3.0f;
    public float MaxExtendedLifeTime = 9.0f;
    float m_lifeTimer = 0.0f;

    bool m_dead = false;
    private void Update() {
        m_lifeTimer += Time.deltaTime;
        if (m_lifeTimer >= LifeTime && !m_dead) { Die(); }
    }

    public void Extend() {
        m_lifeTimer = Mathf.Max(m_lifeTimer - 2.0f, LifeTime - MaxExtendedLifeTime);
    }

    void Die() {
        m_dead = true;
        onDeath?.Invoke();

        DOTween.To(() => FireLight.range, (float value) => FireLight.range = value, 0.0f, 1.4f);

        Particles.Stop(true);
        Particles.transform.parent = null;
        Particles.transform.DOMove(Particles.transform.position, 3.5f).onComplete += () => { Destroy(Particles.gameObject); };

        DOTween.To(() => FireProjector.orthographicSize, (float value) => FireProjector.orthographicSize = value, 0.0f, 1.4f).onComplete += () => {
            Destroy(gameObject);
        };
    }
}
