using System;

namespace UnityEngine.Rendering.Universal{
    
    [Serializable, VolumeComponentMenu("Post-processing/PostFogs")]
    public class PostFog  : VolumeComponent, IPostProcessComponent{

        public ClampedFloatParameter fogDensity = new ClampedFloatParameter(0f, 0f, 3f);

        public ColorParameter fogStartColor = new ColorParameter(Color.white, true, true, false);
        public ColorParameter fogEndColor = new ColorParameter(Color.white, true, true, false);

        public FloatParameter fogStart = new FloatParameter(0f);
        public FloatParameter fogEnd = new FloatParameter(2f);
        
        public TextureParameter noiseTexture = new TextureParameter(null);
        public ClampedFloatParameter fogXSpeed = new ClampedFloatParameter(0.1f, -0.5f, 0.5f);
        public ClampedFloatParameter fogYSpeed = new ClampedFloatParameter(0.1f, -0.5f, 0.5f);
        public ClampedFloatParameter noiseAmount = new ClampedFloatParameter(1f, 0f, 3f);
        public ClampedFloatParameter skyDesity = new ClampedFloatParameter(0f, 0f, 1f);
        
        public bool IsActive(){
            return fogDensity.value > 0;
        }

        public bool IsTileCompatible(){
            return false;
        }
    }
}