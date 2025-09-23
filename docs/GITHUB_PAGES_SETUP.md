# Configuración de GitHub Pages para MkDocs

## 🚀 Pasos para Habilitar GitHub Pages

### 1. Configurar GitHub Pages en el Repositorio

1. Ve a tu repositorio en GitHub: `https://github.com/keikolatam/dapp-monorepo`
2. Haz clic en **Settings** (Configuración)
3. En el menú lateral, busca **Pages**
4. En **Source**, selecciona **GitHub Actions**
5. Guarda la configuración

### 2. Verificar el Workflow

El archivo `.github/workflows/deploy-docs.yml` ya está configurado y se ejecutará automáticamente cuando:
- Hagas push a la rama `main` o `master`
- Modifiques archivos en el directorio `docs/`
- Modifiques el archivo del workflow

### 3. Acceder a la Documentación

Una vez configurado, tu documentación estará disponible en:
- **URL de GitHub Pages**: `https://keikolatam.github.io/dapp-monorepo/`
- **URL configurada en mkdocs.yml**: `https://keikolatam.github.io/dapp-monorepo`

## 🔧 Configuración Actual

- **Tema**: Material for MkDocs
- **Directorio de documentos**: `docs/content/`
- **Directorio de salida**: `site/`
- **Rama de despliegue**: `gh-pages` (manejado automáticamente por GitHub Actions)

## 📝 Comandos Útiles

### Desarrollo Local
```bash
# Activar entorno virtual
source venv/bin/activate

# Servir localmente
cd docs && mkdocs serve

# Construir documentación
cd docs && mkdocs build
```

### Despliegue Manual (alternativo)
```bash
# Si prefieres desplegar manualmente
cd docs && mkdocs gh-deploy
```

## ⚠️ Notas Importantes

1. **Primer despliegue**: Puede tomar unos minutos en completarse
2. **Permisos**: Asegúrate de que GitHub Pages esté habilitado en la configuración del repositorio
3. **Rama**: El workflow está configurado para las ramas `main` y `master`
4. **Triggers**: Solo se despliega cuando hay cambios en `docs/` o el workflow

## 🔍 Solución de Problemas

### Si el despliegue falla:
1. Verifica que GitHub Pages esté habilitado
2. Revisa los logs del workflow en la pestaña **Actions**
3. Asegúrate de que no hay errores en `mkdocs.yml`

### Si la página no carga:
1. Espera unos minutos (puede tomar tiempo en propagarse)
2. Verifica la URL en la configuración de Pages
3. Revisa que el workflow se haya ejecutado exitosamente
