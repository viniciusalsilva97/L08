#INCLUDE 'Totvs.ch'
#INCLUDE 'Fwmvcdef.ch'


/*/{Protheus.doc} User Function InstMvc
    Mvc referente aos instrutores
    @type  Function
    @author Vinícius Silva
    @since 27/03/2023
/*/
User Function InstMvc()
    Local cAlias := "ZZI"
    Local cTitle := "Cadastro de Instrutores"
    Local oMark   := FwMarkBrowse():New()

    oMark:SetAlias(cAlias)
    oMark:SetDescription(cTitle)
    oMark:SetFieldMark("ZZI_MARC")

    oMark:AddButton("Exc. Marcados", "U_Delet"  , 5, 1)

    oMark:DisableDetails()
    oMark:DisableReport()

    oMark:Activate()
Return 

Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.InstMvc" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.InstMvc" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.InstMvc" OPERATION 5 ACCESS 0
    
Return aRotina

Static Function ModelDef()
    //? Validações de Modelo
    Local bModelPos    := {|oModel| ValInst(oModel)}

    Local oModel   := MPFormModel():New("InstMvc_M",,bModelPos)
    Local oStruZZI := FWFormStruct(1, "ZZI")

    oModel:AddFields("ZZIMASTER",,oStruZZI)

    oModel:SetPrimaryKey({"ZZI_CODIGO"})

Return oModel

Static Function ViewDef()
    Local oModel   := FwLoadModel("InstMvc") 
    Local oStruZZI := FWFormStruct(2, "ZZI")
    Local oView    := FwFormView():New()

    oView:SetModel(oModel) 
    oView:AddField("VIEW_ZZI", oStruZZI, "ZZIMASTER")

Return oView

User Function Delet()
    Local nQuantAlunos 
    DbSelectArea("ZZI")

    nQuantAlunos := ZZI -> ZZI_QUANTA

    if nQuantAlunos > 0
        
        Help(Nil, Nil, "Não autorizado!", Nil, "Esse instrutor tem pelo menos 1 aluno", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Ele só poderá ser excluido quando não tiver mais alunos."})

    elseif MsgYesNo("Você deseja fazer a exclusão desse instrutor?")

        ZZI->(DbGoTop())

        while ZZI->(!EOF())
            if oMark:IsMark()
                RecLock("ZZI", .F.)
                    ZZI->(DbDelete())
                ZZI->(MsUnlock())
            endif
            ZZI->(DbSkip())
        end
    endif

    oMark:Refresh(.T.)
Return 

Static Function ValInst(oModel)
    Local lRet          := .T.
    Local nOper         := oModel:GetOperation()
    Local cEscolaridade := AllTrim(oModel:GetValue("ZZIMASTER", "ZZI_ESCOLA"))

    Local dDataNasci    := oModel:GetValue("ZZIMASTER", "ZZI_NASC")
    Local nMaioridade    := DateDiffYear(DATE(), dDataNasci)

    Local dDataHabilita := oModel:GetValue("ZZIMASTER", "ZZI_DTHAB")
    Local nAnosHabilita := DateDiffYear(DATE(), dDataHabilita)

    if nOper == 3
        if  cEscolaridade == "1 - Ensino Fundamental" 
            lRet := .F.
            Help(Nil, Nil, "Não autorizado!", Nil, "Esse instrutor não tem o ensino médio completo", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Ele precisa concluir os estudos."})
        endif

        if nMaioridade < 21
            lRet := .F.
            Help(Nil, Nil, "Não autorizado!", Nil, "Esse instrutor não atingiu a maioridade", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Ele precisa fazer mais aniversários."})
        endif

        if nAnosHabilita < 2
            lRet := .F.
            Help(Nil, Nil, "Não autorizado!", Nil, "Esse instrutor não atingiu 2 anos de habilitado", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Ele precisa dirigir mais."})
        endif
    endif

    if nOper == 5 .AND. ZZI -> ZZI_QUANTA > 0
        lRet := .F.
        Help(Nil, Nil, "Não autorizado!", Nil, "Esse instrutor tem pelo menos 1 aluno", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Ele só poderá ser excluido quando não tiver mais alunos."})
    endif

Return lRet 
