 -- 1. Captura as funções originais de forma ultra-segura
-- Tentamos capturar por prioridade para evitar o erro de 'nil'
if not HTK_NATIVE_DOFILE then
  HTK_NATIVE_DOFILE = dofile or _G.dofile
  HTK_NATIVE_IMPORT = g_ui.importStyle
  -- Se ainda assim for nil (alguns clients protegem a g_ui), tentamos via global direta
  if not HTK_NATIVE_IMPORT then
      HTK_NATIVE_IMPORT = importStyle
  end
end



-- Verificação de segurança: Se falhar tudo, emitimos um aviso, mas não deixamos o script quebrar

if not HTK_NATIVE_DOFILE then
  warn("[HTK] ERRO: Nao foi possivel encontrar a funcao nativa 'dofile'.")
end
local KEY_API = "http://127.0.0.1:8081/"
virtualFS = {}
-- 2. Função de busca segura

local function getVirtualContent(path)
  if not path or type(virtualFS) ~= "table" then return nil end
  local normalized = path:gsub("^/", "")
  return virtualFS[normalized]
end



-- 3. Função cloudDofile Unificada

function cloudDofile(path)
  local content = getVirtualContent(path)
  if not content then
      -- Usa o backup que fizemos no passo 1
      if HTK_NATIVE_DOFILE then
          return HTK_NATIVE_DOFILE(path)
      else
          return nil
      end

  end



  local chunk, err = loadstring(content, "@" .. path)
  if not chunk then
      warn("[HTK] Erro LUA: " .. path .. " | " .. tostring(err))
      return
  end



  local ok, res = pcall(chunk)

  if not ok then warn("[HTK] Erro Exec: " .. tostring(res)) end

  return res

end



-- 4. Função cloudImport Unificada

function cloudImport(path)

  local content = getVirtualContent(path)

 

  if not content or #content < 5 then

      if HTK_NATIVE_IMPORT then

          pcall(function() HTK_NATIVE_IMPORT(path) end)

      end

      return

  end



  -- Limpeza de lixo e espaços

  content = content:gsub("^[%s%c]+", ""):gsub("[%s%c]+$", "")



  local tmpPath = "/tmp_htk_" .. path:gsub("[^%a%d]", "_") .. ".otui"

  g_resources.writeFileContents(tmpPath, content)

 

  if g_resources.fileExists(tmpPath) then

      pcall(function() HTK_NATIVE_IMPORT(tmpPath) end)

  end

end



-- 5. Sobrescrevendo as globais de forma segura
-- Usamos o ambiente global se disponível, senão apenas declaramos a função

dofile = cloudDofile
importStyle = cloudImport
g_ui.importStyle = cloudImport

-- =========================
-- UI LOGIN
-- =========================

local parent = modules and modules.game_interface and modules.game_interface.getRootPanel() or rootWidget

welcomeCustom = setupUI([[
Panel
  id: gankUI
  size: 350 140
  background-color: #111111ee
  border-width: 1
  border-color: #f72d09
  draggable: true
  focusable: true
  phantom: false
  visible: false



  Label
    id: titleLabel
    text: BEM VINDO A CUSTOM HTK
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    margin-top: 15
    color: #f72d09
    font: verdana-11px-bold



  Label
    id: keyLabel
    text: Digite sua Key de Acesso:
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 15
    margin-left: 20
    color: #dfdfdf


  TextEdit
    id: keyInput
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin: 5 20
    height: 20
    background-color: #222222
    border-width: 1
    border-color: #444444
    color: #ffffff
    focusable: true

  Button
    id: btnAtivar
    text: ATIVAR AGORA
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin: 12 20
    height: 28
    color: #ffffff
    background-color: #f72d09
    font: verdana-11px-bold
]], parent)



-- Centralizar
local function centralize()
    local root = modules.game_interface.getRootPanel()
    welcomeCustom:move((root:getWidth()/2) - (welcomeCustom:getWidth()/2), (root:getHeight()/2) - (welcomeCustom:getHeight()/2))
end

-- =========================
-- VALIDAÇÃO DA KEY
-- =========================

local function validateKey(key, callback)
  if not key or key == "" then callback(false) return end
  local url = KEY_API .. "activate?key=" .. key
  warn("[HTK] Validando: " .. key)
  HTTP.get(url, function(data, err)
    if err then
      warn("Erro HTTP: " .. tostring(err))
      callback(false)
      return
    end
    -- Versão Antiga: loadstring direto no dado vindo do servidor

    local chunk, loadErr = loadstring(data)
    if not chunk then
      warn("[HTK] Erro no loadstring: " .. (loadErr or "unknown"))
      callback(false)
      return
    end
    local files = chunk() -- Executa o código para retornar a tabela
    if type(files) == "table" then
        virtualFS = files
        warn("[HTK] Sucesso! Iniciando scripts...")
        schedule(100, function()
            dofile("scripts/main.lua")
            callback(true)
            return
        end)

    else
        warn("[HTK] Dados retornados não são uma tabela.")
        callback(false)
    end
  end)
end



-- =========================
-- EVENTOS
-- =========================
welcomeCustom.btnAtivar.onClick = function()
    local key = welcomeCustom.keyInput:getText():gsub("%s+", "")
    validateKey(key, function(valid)
        if valid then
            storage.userKey = key
            welcomeCustom:setVisible(false)
        else
            warn("[HTK] Falha na ativação.")
        end

    end)

end

local function startLoader()
    centralize()
    -- Se tiver key salva, tenta carregar direto
    if storage.userKey and storage.userKey ~= "" then
        validateKey(storage.userKey, function(valid)
            if not valid then
                welcomeCustom:setVisible(true)
                welcomeCustom:raise()
            else
                warn("[HTK] Key salva validada com sucesso!")
                welcomeCustom:setVisible(false)
            end

        end)

    else
        welcomeCustom:setVisible(true)
        welcomeCustom:raise()
    end
end

startLoader()