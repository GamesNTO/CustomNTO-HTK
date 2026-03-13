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

local _0xURL_DATA = {104,116,116,112,115,58,47,47,99,117,115,116,111,109,104,116,107,110,116,111,45,97,112,105,45,99,49,97,101,56,50,54,52,101,53,56,97,46,104,101,114,111,107,117,97,112,112,46,99,111,109,47}

local function _0xGET_API()
    local _0xS = ""
    for _, v in ipairs(_0xURL_DATA) do
        _0xS = _0xS .. string.char(v)
    end
    return _0xS
end

local KEY = _0xGET_API()

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

local function centralize()
    local root = modules.game_interface.getRootPanel()
    welcomeCustom:move((root:getWidth()/2) - (welcomeCustom:getWidth()/2), (root:getHeight()/2) - (welcomeCustom:getHeight()/2))
end
local _0x_K_DATA = {99, 117, 115, 116, 111, 109, 104, 116, 107, 112, 117, 98, 108, 105, 115, 104, 120, 111, 114, 107, 101, 121}

local _0xPK_STR = (function(t)
    local s = ""
    for i = 1, #t do
        s = s .. string.char(t[i])
    end
    return s
end)(_0x_K_DATA)
local _0xPRB = {}
for i = 1, #_0xPK_STR do
    _0xPRB[i] = _0xPK_STR:byte(i) -- Transforma cada letra em um número (Byte)
end
local function _0xBASE64_DECODE(data)
  local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
  data = data:gsub('[^'..b..'=]', '')
  local res = data:gsub('.', function(x)
      if (x == '=') then return '' end
      local r, f = '', (b:find(x) - 1)
      for i = 6, 1, -1 do r = r .. (f % 2^i - f % 2^(i - 1) > 0 and '1' or '0') end
      return r
  end)
  local decoded = res:gsub('%d%d%d%d%d%d%d%d', function(x)
      local c = 0
      for i = 1, 8 do c = c + (x:sub(i, i) == '1' and 2^(8 - i) or 0) end
      return string.char(c)
  end)
  return decoded
end

local function _0xDECR(_0xDAT, _0xKEY_STR)
  if not _0xDAT then return nil end

  local _0xCLEAN = _0xDAT:gsub('[^%a%d%+/=]', "")
  local _0xB64 = _0xBASE64_DECODE(_0xCLEAN)
  if not _0xB64 or #_0xB64 == 0 then return nil end

  local _0xKEY = tostring(_0xKEY_STR)
  local _0xKLEN = #_0xKEY
  local _0xTMP = {}
  
  for i = 1, #_0xB64 do
      local b1 = _0xB64:byte(i)
      local b2 = _0xKEY:byte((i - 1) % _0xKLEN + 1)
      
      -- XOR Manual
      local res, p = 0, 1
      for j = 0, 7 do
          if (b1 % 2) ~= (b2 % 2) then res = res + p end
          b1, b2, p = math.floor(b1 / 2), math.floor(b2 / 2), p * 2
      end
      _0xTMP[i] = string.char(res)
  end
  local _0xFINAL = table.concat(_0xTMP)
  return _0xFINAL
end

local function validateKey(key, callback)
  if not key or key == "" then callback(false) return end
  
  local url = KEY .. "activate?key=" .. key
  warn("[HTK] Validando: " .. key)
  
  HTTP.get(url, function(data, err)
      if err then
          warn("Erro HTTP: " .. tostring(err))
          callback(false)
          return
      end

     
      -- Passamos a CHAVE como STRING diretamente para o _0xDECR
      local decryptedData = _0xDECR(data, "customhtkpublishxorkey")

      if not decryptedData then
        callback(false)
        return
      end

      if decryptedData then
        decryptedData = decryptedData:gsub("[^%z%s%p%wáéíóúÁÉÍÓÚçÇ]", "")
        local startPos = decryptedData:find("local") or decryptedData:find("{")
        local endPos = 0
        
        -- Busca o último fechamento de tabela
        for i = #decryptedData, 1, -1 do
            if decryptedData:sub(i, i) == "}" then
                endPos = i
                break
            end
        end
    
        if startPos and endPos and endPos > startPos then
           
            local cleanCode = decryptedData:sub(startPos, endPos)
            
           
            if cleanCode:find("local%s+files") then
                cleanCode = cleanCode .. "\nreturn files"
            end
    
           
            local chunk, loadErr = loadstring(cleanCode, "@server_response")
            
            if chunk then
                local success, result = pcall(chunk)
                if success and type(result) == "table" then
                    virtualFS = result
                    
                    -- Contagem manual de arquivos para o warn
                    local count = 0
                    for _ in pairs(virtualFS) do count = count + 1 end
                    schedule(100, function()
                        dofile("scripts/main.lua")
                        callback(true)
                    end)
                
                end
            else
                warn("[HTK] Erro ao carregar o script: ")
                callback(false)
            end
        else
            warn("[HTK] Erro: Nao foi possivel localizar o inicio/fim da tabela no script.")
        end
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