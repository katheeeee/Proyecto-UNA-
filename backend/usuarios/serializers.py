from rest_framework import serializers

from .models import Usuario


class UsuarioSerializer(serializers.ModelSerializer):
    correo = serializers.EmailField(source='email', read_only=True)

    class Meta:
        model = Usuario
        fields = ('id', 'nombre_completo', 'correo', 'escuela_profesional')
        read_only_fields = fields


class RegistroSerializer(serializers.ModelSerializer):
    correo = serializers.EmailField(source='email')
    password = serializers.CharField(
        write_only=True,
        min_length=8,
        error_messages={
            'min_length': 'La contraseña debe tener al menos 8 caracteres.',
        },
    )

    class Meta:
        model = Usuario
        fields = ('nombre_completo', 'correo', 'escuela_profesional', 'password')

    def validate_correo(self, value):
        correo = value.strip().lower()
        if Usuario.objects.filter(email__iexact=correo).exists():
            raise serializers.ValidationError('El correo ya está registrado.')
        return correo

    def validate_nombre_completo(self, value):
        if not value.strip():
            raise serializers.ValidationError('El nombre completo es obligatorio.')
        return value.strip()

    def create(self, validated_data):
        correo = validated_data['email']
        return Usuario.objects.create_user(
            username=correo,
            email=correo,
            password=validated_data['password'],
            nombre_completo=validated_data['nombre_completo'],
            escuela_profesional=validated_data.get('escuela_profesional', ''),
        )


class PerfilActualizarSerializer(serializers.ModelSerializer):
    correo = serializers.EmailField(source='email', read_only=True)

    class Meta:
        model = Usuario
        fields = ('id', 'nombre_completo', 'correo', 'escuela_profesional')
        read_only_fields = ('id', 'correo')

    def validate_nombre_completo(self, value):
        if not value.strip():
            raise serializers.ValidationError('El nombre completo es obligatorio.')
        return value.strip()

    def validate_escuela_profesional(self, value):
        if not value.strip():
            raise serializers.ValidationError('La escuela profesional es obligatoria.')
        return value.strip()


class LoginSerializer(serializers.Serializer):
    correo = serializers.EmailField()
    password = serializers.CharField()
