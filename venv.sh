#!/bin/bash

# Definición de colores para la interfaz
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${CYAN}=============================================${NC}"
echo -e "${CYAN}      Iniciando Configuración del Proyecto   ${NC}"
echo -e "${CYAN}=============================================${NC}"

# 1. Crear entorno virtual
echo -e "\n${YELLOW}[1/3] Creando entorno virtual (venv)...${NC}"
if python3 -m venv venv; then
    echo -e "${GREEN}✔ Entorno virtual creado exitosamente.${NC}"
else
    echo -e "${RED}✘ Error al crear el entorno virtual.${NC}"
    exit 1
fi

# 2. Activar entorno
echo -e "\n${YELLOW}[2/3] Activando entorno virtual...${NC}"
source venv/bin/activate

if [[ "$VIRTUAL_ENV" != "" ]]; then
    echo -e "${GREEN}✔ Entorno activado correctamente.${NC}"
else
    echo -e "${RED}✘ No se pudo activar el entorno.${NC}"
    exit 1
fi

# 3. Instalar dependencias
echo -e "\n${YELLOW}[3/3] Instalando dependencias desde requirements.txt...${NC}"
if pip install -r requirements.txt; then
    echo -e "${GREEN}✔ Dependencias instaladas correctamente.${NC}"
else
    echo -e "${RED}✘ Error al instalar dependencias.${NC}"
    exit 1
fi

echo -e "\n${CYAN}=============================================${NC}"
echo -e "${GREEN}      ¡Configuración finalizada con éxito! 🚀 ${NC}"
echo -e "${CYAN}=============================================${NC}"
echo -e "Para activar el entorno en tu terminal actual, ejecuta:"
echo -e "${YELLOW}source venv/bin/activate${NC}"
