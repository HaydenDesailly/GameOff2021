using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : Singleton<PlayerMovement> {
    [Header("Movement")]
    public float MaxSpeed = 8.0f;
    public float MaxSprintSpeed = 14.0f;
    public float Acceleration = 5.0f;
    public float Deceleration = 8.0f;

    [Header("Look")]
    public float LookSensitivity = 0.8f;

    [Header("Components")]
    public Camera PlayerCamera;

    [Header("Keybindings")]
    public KeyCode Forward = KeyCode.W;
    public KeyCode Backward = KeyCode.S;
    public KeyCode Left = KeyCode.A;
    public KeyCode Right = KeyCode.D;
    public KeyCode Sprint = KeyCode.LeftShift;
    public KeyCode Jump = KeyCode.Space;

    protected Vector3 m_moveDir = Vector3.zero;
    protected Vector3 m_velocity = Vector3.zero;
    protected Vector2 m_lookAngles = Vector2.zero;

    protected float CurrentMaxSpeed => Input.GetKey(Sprint) ? MaxSprintSpeed : MaxSpeed;

    protected Rigidbody m_rb;

    protected override void Awake() {
        base.Awake();

        m_rb = GetComponent<Rigidbody>();
    }

    private void Update() {
        // Handle focusing
        if (Application.isFocused && (Cursor.lockState != CursorLockMode.Locked || Cursor.visible)) {
            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;
        }

        // Handle looking
        m_lookAngles += new Vector2(-Input.GetAxis("Mouse Y"), Input.GetAxis("Mouse X")) * LookSensitivity;
        m_lookAngles.x = Mathf.Clamp(m_lookAngles.x, -85.0f, 85.0f);
        transform.rotation = Quaternion.Euler(0.0f, m_lookAngles.y, 0.0f);
        PlayerCamera.transform.rotation = Quaternion.Euler(m_lookAngles.x, m_lookAngles.y, 0.0f);

        // Handle movement
        m_moveDir = Vector3.zero;
        if (Input.GetKey(Forward)) { m_moveDir += Vector3.forward; }
        if (Input.GetKey(Backward)) { m_moveDir += Vector3.back; }
        if (Input.GetKey(Left)) { m_moveDir += Vector3.left; }
        if (Input.GetKey(Right)) { m_moveDir += Vector3.right; }
        m_moveDir = transform.rotation * m_moveDir.normalized;

        Vector3 verticalVelocity = Vector3.Project(m_rb.velocity, Vector3.up);
        if (m_moveDir.sqrMagnitude > 0.0f) {
            float lerpStrength = Time.deltaTime * (Vector3.Dot(m_velocity, m_moveDir) > 0 ? Acceleration : Deceleration);
            m_velocity = Vector3.Lerp(m_velocity, m_moveDir * CurrentMaxSpeed, lerpStrength);
        }
        else { m_velocity = Vector3.Lerp(m_velocity, Vector3.zero, Time.deltaTime * Deceleration); }

        m_rb.velocity = verticalVelocity + m_velocity;
    }
}
