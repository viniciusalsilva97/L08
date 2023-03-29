#INCLUDE 'Totvs.ch'
#INCLUDE 'Fwmvcdef.ch'


/*/{Protheus.doc} User Function AutoMvc
    Mvc referente aos veículos
    @type  Function
    @author Vinícius Silva
    @since 27/03/2023
/*/
User Function AutoMvc()
    Local cAlias := "ZZV"
    Local cTitle := "Cadastro de Veículos"
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cAlias) 
    oBrowse:SetDescription(cTitle)    
    oBrowse:DisableDetails()
    oBrowse:DisableReport() 
    oBrowse:Activate() 
Return 

Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.AutoMvc" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.AutoMvc" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.AutoMvc" OPERATION 5 ACCESS 0
    
Return aRotina

Static Function ModelDef()
    Local oModel   := MPFormModel():New("AUTOMVC_M")
    Local oStruZZV := FWFormStruct(1, "ZZV")

    oModel:AddFields("ZZVMASTER",,oStruZZV)

    oModel:SetPrimaryKey({"ZZV_COD"})

Return oModel

Static Function ViewDef()
    Local oModel   := FwLoadModel("AutoMvc") 
    Local oStruZZV := FWFormStruct(2, "ZZV")
    Local oView    := FwFormView():New()

    oView:SetModel(oModel) 
    oView:AddField("VIEW_ZZV", oStruZZV, "ZZVMASTER")

Return oView



