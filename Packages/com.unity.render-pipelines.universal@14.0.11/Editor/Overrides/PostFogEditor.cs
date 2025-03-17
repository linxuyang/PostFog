using UnityEngine.Rendering.Universal;

namespace UnityEditor.Rendering.Universal{
    [VolumeComponentEditor(typeof(PostFog))]
    public class PostFogEditor : VolumeComponentEditor{
        
        SerializedDataParameter fogDensity;
        SerializedDataParameter fogStartColor;
        SerializedDataParameter fogEndColor;
        SerializedDataParameter fogStart;
        SerializedDataParameter fogEnd;
        SerializedDataParameter noiseTexture;
        SerializedDataParameter fogXSpeed;
        SerializedDataParameter fogYSpeed;
        SerializedDataParameter noiseAmount;
        SerializedDataParameter skyDesity;
        
        public override void OnEnable()
        {
            var o = new PropertyFetcher<PostFog>(serializedObject);

            fogDensity = Unpack(o.Find(x => x.fogDensity));
            fogStartColor = Unpack(o.Find(x => x.fogStartColor));
            fogEndColor = Unpack(o.Find(x => x.fogEndColor));
            fogStart = Unpack(o.Find(x => x.fogStart));
            fogEnd = Unpack(o.Find(x => x.fogEnd));
            noiseTexture = Unpack(o.Find(x => x.noiseTexture));
            fogXSpeed = Unpack(o.Find(x => x.fogXSpeed));
            fogYSpeed = Unpack(o.Find(x => x.fogYSpeed));
            noiseAmount = Unpack(o.Find(x => x.noiseAmount));
            skyDesity = Unpack(o.Find(x => x.skyDesity));
        }

        public override void OnInspectorGUI()
        {
            EditorGUILayout.LabelField("HeightFog", EditorStyles.miniLabel);
            PropertyField(fogDensity);
            PropertyField(fogStartColor);
            PropertyField(fogEndColor);
            PropertyField(fogStart);
            PropertyField(fogEnd);
            PropertyField(noiseTexture);
            PropertyField(fogXSpeed);
            PropertyField(fogYSpeed);
            PropertyField(noiseAmount);
            PropertyField(skyDesity);
        }
    }
}