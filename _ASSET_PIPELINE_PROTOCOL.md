# ASSET PIPELINE PROTOCOL: BABCIA
Version: 1.0 (The 2nd Tone Lock)

This is the MANDATORY 2-step process for generating any visual asset (Characters, Props, UI) for the Babcia project. No agent should generate images without following this sequence exactly.

---

## STEP 1: THE CONSTRAINT LOCK 🔐
Before uploading any images or asking for an asset, you MUST send this prompt to the Image Generation AI to lock the latent space into our project's "Soul."

### Template (Step 1):
> You are creating a consistent asset pack for the Babcia project. You must lock your generation logic to the following parameters:
>
> **STYLE / MATERIAL (Required):**
> - **Material:** Handmade polymer clay / claymorphic look (NOT plastic, NOT vinyl, NOT CGI).
> - **Rendering:** Matte, chalky surface, high roughness (≈0.9), low specular (≈0.1), subtle subsurface warmth (soft, not glossy).
> - **Details:** Add tiny physical imperfections: faint fingerprints or clay texture (very subtle).
>
> **LIGHTING / CAMERA (Required):**
> - **Lighting:** Soft studio product lighting: softbox key + gentle fill + subtle rim light.
> - **Edges:** Crisp edges, high shutter speed look (NO motion blur).
> - **Camera:** Front-facing, slight 5–10° downward tilt. Consistent across all assets.
>
> **CANVAS / BACKGROUND (Required):**
> - **Canvas:** 1024×1024.
> - **Background:** Solid flat chroma green #00FF00 ONLY. No gradient. No shadow on “floor”. No vignette.
> - **Cleanliness:** No text, no logos, no watermarks.
>
> **FRAMING RULES (General):**
> - **Full-Body / LARGE Objects:** Whole asset fully visible. Centered. ~12–15% empty padding around silhouette.
> - **Face Close-ups:** Head fills ~75% of frame, centered.
> - **Icons / Small Props:** Item centered, fills ~70% of frame, generous padding for UI clipping.
>
> **ABSOLUTELY AVOID:**
> glossy, shiny, plastic, vinyl, CGI, game render, low poly, bokeh, depth-of-field blur, bloom, lens flare, fog, background props.
>
> **CONFIRMATION:**
> Reply with "Asset Pack Constraints Confirmed" and a 3-point summary of the material, lighting, and background locks.

---

## STEP 2: THE VISUAL ANCHOR & BUILD ⚓️
ONLY after the AI confirms "Asset Pack Constraints Confirmed," proceed to Step 2. **Upload the most relevant Babcia reference image** along with the following prompt.

### Template (Step 2):
> Using the uploaded source image as the ONLY reference for the material and world-identity, create a “normalized reference” version of: **[DESCRIBE ASSET HERE, e.g., A Ceramic Bowl]**.
>
> **GOAL:**
> Render the requested asset so it looks 1:1 like it belongs in the same world as the reference. Do NOT redesign or “improve” the aesthetic.
>
> **OUTPUT SPEC:**
> - **Identity Match:** Exact material, colors, and matte clay texture from source.
> - **Framing:** **[SELECT ONE: Full-body / Headshot / Centered Prop]**. 
> - **Padding:** ~12–15% empty space around the outermost silhouette.
> - **Background:** Solid flat chroma green #00FF00.
> - **Cleanliness:** No text, no logos, no watermarks, no shadows.
>
> **Deliver exactly one image: R#_REF_NORMALIZED.**

---

## RULE OF THREE
1. **Never** skip Step 1.
2. **Never** let the AI "improve" the design.
3. **Always** use #00FF00 for 3D renders.
