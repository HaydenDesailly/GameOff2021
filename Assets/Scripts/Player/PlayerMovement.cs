using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : Singleton<PlayerMovement> {
    [Header("Movement")]
    public float MaxSpeed = 8.0f;
    public float MaxSprintSpeed = 14.0f;
    public float Acceleration = 5.0f;
    public float Deceleration = 8.0f;
    [Range(0.0f, 1.0f)] public float AirControl = 0.2f;
    public float JumpStrength = 8.0f;

    [Header("Grounding")]
    public float MaximumGroundAngle = 50.0f;
    public LayerMask GroundedMask;
    public Transform GroundCastOrigin;
    public float GroundStickCastLength = 0.9f;

    [Header("Look")]
    public float LookSensitivity = 0.8f;

    [Header("Components")]
    public Camera PlayerCamera;
    public CapsuleCollider GroundedCapsule;
    public CapsuleCollider FallingCapsule;
    public UnityEngine.UI.Toggle GroundedToggle;

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
    protected bool m_grounded = false;
    protected float m_groundCastDepth;
    protected float m_jumpGroundedCD = 0.2f;
    protected float m_jumpTimer = 99.0f;

    protected float m_snareTime = 0.4f;
    protected float m_snareTimer = 99.0f;
    protected float CurrentSnareMultiplier {
        get {
            float x = Mathf.Clamp01(m_snareTimer / m_snareTime);
            return x * x;
        }
    }

    protected override void Awake() {
        base.Awake();

        m_rb = GetComponent<Rigidbody>();
        m_groundCastDepth = Vector3.Project(transform.position - GroundCastOrigin.position, transform.up).magnitude - GroundedCapsule.radius;
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

        // Handle Jumping
        HandleJumping();

        // Handle grounding
        HandleGrounding();

        // Handle movement
        m_moveDir = Vector3.zero;
        if (Input.GetKey(Forward)) { m_moveDir += Vector3.forward; }
        if (Input.GetKey(Backward)) { m_moveDir += Vector3.back; }
        if (Input.GetKey(Left)) { m_moveDir += Vector3.left; }
        if (Input.GetKey(Right)) { m_moveDir += Vector3.right; }
        m_moveDir = transform.rotation * m_moveDir.normalized;

        m_snareTimer += Time.deltaTime;
        float movementMultiplier = (!m_grounded ? AirControl : 1.0f) * CurrentSnareMultiplier;
        Vector3 verticalVelocity = Vector3.Project(m_rb.velocity, Vector3.up);
        if (m_moveDir.sqrMagnitude > 0.0f) {
            float lerpStrength = Time.deltaTime * (Vector3.Dot(m_velocity, m_moveDir) > 0 ? Acceleration : Deceleration) * movementMultiplier;
            m_velocity = Vector3.Lerp(m_velocity, m_moveDir * CurrentMaxSpeed, lerpStrength);
        }
        else { m_velocity = Vector3.Lerp(m_velocity, Vector3.zero, Time.deltaTime * Deceleration * movementMultiplier); }

        m_rb.velocity = verticalVelocity + m_velocity;
    }

    private void FixedUpdate() {
        Vector3 verticalVelocity = Vector3.Project(m_rb.velocity, Vector3.up);
        m_velocity = m_rb.velocity - verticalVelocity;
    }

    protected void HandleJumping() {
        m_jumpTimer += Time.deltaTime;
        if (m_grounded && m_jumpTimer >= m_jumpGroundedCD && m_grounded && Input.GetKeyDown(Jump)) {
            m_jumpTimer = 0.0f;
            m_grounded = false;
            Vector3 jumpVel = m_rb.velocity;
            jumpVel.y = JumpStrength;
            m_rb.velocity = jumpVel;
        }
    }

    protected void HandleGrounding() {
        float depth = m_groundCastDepth + (m_grounded ? GroundStickCastLength : 0.02f);
        m_grounded = false;
        if (m_jumpTimer >= m_jumpGroundedCD) {
            Ray ray = new Ray(GroundCastOrigin.position, Vector3.down);
            if (Physics.SphereCast(ray, GroundedCapsule.radius * 0.99f, out RaycastHit hit, depth, GroundedMask)) {
                bool stick = true;
                if (Vector3.Angle(Vector3.up, hit.normal) <= MaximumGroundAngle) { m_grounded = true; }
                else {
                    stick = hit.distance < m_groundCastDepth + 0.48f;
                    if (stick) {
                        float bounceStrength = 0.8f;
                        Vector3 bounceDirection = (hit.normal - Vector3.Project(hit.normal, Vector3.up)).normalized;
                        Vector3 projection = Vector3.Project(m_velocity, bounceDirection);
                        Vector3 residual = m_velocity - projection;
                        if (Vector3.Dot(projection, bounceDirection) > 0) {
                            if (projection.magnitude < bounceStrength) { projection = Vector3.Lerp(projection, bounceDirection * bounceStrength, Time.deltaTime * 16.0f); }
                        }
                        else { projection = Vector3.Lerp(projection, bounceDirection * bounceStrength, Time.deltaTime * 16.0f); }
                        m_velocity = projection + residual;
                        //m_snareTimer = 0.0f;
                    }
                }

                if (stick) {
                    // Stick to ground
                    Vector3 translation = hit.point - transform.position;
                    transform.position += Vector3.Project(translation, Vector3.up) * Time.deltaTime * 8.0f;
                }
            }

            m_rb.useGravity = !m_grounded;
            if (m_grounded) { m_rb.velocity = Vector3.zero; }
            GroundedToggle.isOn = m_grounded;

            FallingCapsule.enabled = !m_grounded;
        }
    }
}
