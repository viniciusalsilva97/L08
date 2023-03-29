#INCLUDE 'Totvs.ch'
#INCLUDE 'Fwmvcdef.ch'

/*/{Protheus.doc} User Function CnhMvc
    Mvc referente às categorias de CNH
    @type  Function
    @author Vinícius Silva
    @since 27/03/2023
/*/
User Function CnhMvc()
    Local cAlias := "ZZH"
    Local cTitle := "Cadastro das Categorias de CNH"
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cAlias) 
    oBrowse:SetDescription(cTitle)    
    oBrowse:DisableDetails()
    oBrowse:DisableReport() 
    oBrowse:Activate() 
Return 

Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.CnhMvc" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.CnhMvc" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.CnhMvc" OPERATION 5 ACCESS 0
    
Return aRotina

Static Function ModelDef()

    //? Validações de Modelo
    Local bModelPos    := {|oModel| ValSigla(oModel)}


    Local oModel    := MPFormModel():New("CNHMVC_M" ,, bModelPos)
    Local oStruZZH  := FWFormStruct(1, "ZZH")
    Local aGatilho := FwStruTrigger("ZZH_CODV", "ZZH_NOMEV", "ZZV->ZZV_NOME", .T., "ZZV", 1, "xFilial('ZZV')+AllTrim(M->ZZH_CODV)") 
            
    oStruZZH:AddTrigger(aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4])
    oModel:AddFields("ZZHMASTER", /*Owner*/, oStruZZH, ,)
    oStruZZH:SetProperty("ZZH_CODIGO", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,  "GETSXENUM('ZZH', 'ZZH_CODIGO')"))

    oModel:SetPrimaryKey({"ZZH_CODIGO"})

Return oModel

Static Function ViewDef()
    Local oModel   := FwLoadModel("CnhMvc") 
    Local oStruZZH := FWFormStruct(2, "ZZH")
    Local oView    := FwFormView():New()

    oView:SetModel(oModel) 
    oView:AddField("VIEW_ZZH", oStruZZH, "ZZHMASTER")

Return oView

Static Function ValSigla(oModel)
    Local nOper       := oModel:GetOperation()
    Local cSigla      := AllTrim(oModel:GetValue("ZZHMASTER", "ZZH_SIGLA"))
    Local lTudoOk     := .T.
    
    if nOper == 3 .OR. nOper == 4
        if Len(cSigla) == 2
            lTudoOk := .F.
            Help(Nil, Nil, "Não autorizado!", Nil, "A sigla deve conter 1 ou 3 caracteres", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Siga as instruções."})
        endif
    endif 
Return lTudoOk
