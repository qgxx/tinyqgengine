// Ouput data
layout(location = 0) out vec4 outputColor;

layout(location = 0) in vec3 UVW;

void main(){
    outputColor = textureLod(skybox, vec4(UVW, 0), 0);

    // tone mapping
    //outputColor.rgb = reinhard_tone_mapping(outputColor.rgb);
    outputColor.rgb = exposure_tone_mapping(outputColor.rgb);

    // gamma correction
    outputColor.rgb = gamma_correction(outputColor.rgb);
}